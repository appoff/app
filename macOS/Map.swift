import MapKit
import Combine
import Offline

class Map: MKMapView, MKMapViewDelegate, CLLocationManagerDelegate {
    final var subs = Set<AnyCancellable>()
    let geocoder = CLGeocoder()
    let discard = PassthroughSubject<MKPointAnnotation, Never>()
    let type = CurrentValueSubject<_, Never>(Settings.Map.standard)
    let scheme = CurrentValueSubject<_, Never>(Settings.Scheme.auto)
    let mode = CurrentValueSubject<NSAppearance?, Never>(nil)
    let interest = CurrentValueSubject<_, Never>(true)
    let rotate = CurrentValueSubject<_, Never>(true)
    let follow = CurrentValueSubject<_, Never>(true)
    private var first = true
    private let editable: Bool
    private let position = PassthroughSubject<Void, Never>()
    private let manager = CLLocationManager()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, editable: Bool) {
        self.editable = editable
        super.init(frame: .zero)
        isPitchEnabled = false
        showsUserLocation = true
        showsTraffic = false
        userTrackingMode = .none
        register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Marker")
        delegate = self
        
        type
            .removeDuplicates()
            .sink { [weak self] type in
                switch type {
                case .standard:
                    self?.mapType = .standard
                case .satellite:
                    self?.mapType = .satelliteFlyover
                case .hybrid:
                    self?.mapType = .hybridFlyover
                case .emphasis:
                    self?.mapType = .mutedStandard
                }
                
                guard editable else { return }
                
                Task {
                    await cloud.update(map: type)
                }
            }
            .store(in: &subs)
        
        interest
            .removeDuplicates()
            .sink { [weak self] interest in
                self?.pointOfInterestFilter = interest ? .includingAll : .excludingAll
                
                guard editable else { return }
                
                Task {
                    await cloud.update(interest: interest)
                }
            }
            .store(in: &subs)
        
        scheme
            .removeDuplicates()
            .sink { [weak self] scheme in
                switch scheme {
                case .auto:
                    self?.mode.value = nil
                case .light:
                    self?.mode.value = .init(named: .aqua)
                case .dark:
                    self?.mode.value = .init(named: .darkAqua)
                }
                
                guard editable else { return }
                
                Task {
                    await cloud.update(scheme: scheme)
                }
            }
            .store(in: &subs)
        
        rotate
            .removeDuplicates()
            .sink { [weak self] rotate in
                self?.isRotateEnabled = rotate
                
                Task {
                    await cloud.update(rotate: rotate)
                }
            }
            .store(in: &subs)
        
        cloud
            .first()
            .sink { [weak self] in
                self?.rotate.value = $0.settings.rotate
            }
            .store(in: &subs)
        
        position
            .debounce(for: .milliseconds(75), scheduler: DispatchQueue.main)
            .sink { [weak self] in
//                self?.user(span: false)
//                self?.first = false
            }
            .store(in: &subs)
        
//        user(span: true)
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.allowsBackgroundLocationUpdates = true
    }
    
    final func tracker() {
        map
            .selectedAnnotations
            .first
            .map {
                map.deselectAnnotation($0, animated: true)
            }
        
        switch manager.authorizationStatus {
        case .denied, .restricted:
            UIApplication.shared.settings()
        case .notDetermined:
            first = true
            manager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            user(span: true)
            map.follow = true
        @unknown default:
            break
        }
    }
    
    final func mapView(_: MKMapView, didUpdate: MKUserLocation) {
        guard
            map.follow,
            let delta = didUpdate.location.map({ $0.coordinate.delta(other: map.centerCoordinate) }),
            delta > 0.000000015
        else { return }
        
        position.send()
    }
    
    final func mapView(_: MKMapView, viewFor: MKAnnotation) -> MKAnnotationView? {
        switch viewFor {
        case let user as MKUserLocation:
            let view = map.dequeueReusableAnnotationView(withIdentifier: "User") as? User ?? User()
            view.annotation = user
            return view
        case let point as MKPointAnnotation:
            let view = map.dequeueReusableAnnotationView(withIdentifier: "Marker") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: point, reuseIdentifier: "Marker")
            view.glyphImage = .init(named: "Logo")
            view.annotation = point
            view.markerTintColor = .label
            view.animatesWhenAdded = true
            view.displayPriority = .required
            view.canShowCallout = true
            
            if editable {
                let button = UIButton(configuration: .plain(), primaryAction: .init { [weak self] _ in
                    self?.discard.send(point)
                })
                button.frame = .init(x: 0, y: 0, width: 34, height: 40)
                button.setImage(UIImage(systemName: "xmark.circle.fill")?.applyingSymbolConfiguration(.init(hierarchicalColor: .secondaryLabel))?.applyingSymbolConfiguration(.init(font: .systemFont(ofSize: 16, weight: .light))), for: .normal)
                
                view.leftCalloutAccessoryView = button
            }
            
            return view
        default:
            return nil
        }
    }
    
    final func mapView(_: MKMapView, rendererFor: MKOverlay) -> MKOverlayRenderer {
        switch rendererFor {
        case let line as MKMultiPolyline:
            let liner = Liner(multiPolyline: line)
            liner.strokeColor = .label
            return liner
        default:
            return MKTileOverlayRenderer(tileOverlay: rendererFor as! Tiler)
        }
    }
    
    func mapView(_: MKMapView, didSelect: MKAnnotationView) {
        map.follow = false
    }
    
    final func locationManager(_: CLLocationManager, didUpdateHeading: CLHeading) {
        guard
            didUpdateHeading.headingAccuracy >= 0,
            didUpdateHeading.trueHeading >= 0,
            let user = map.annotations.first(where: { $0 === map.userLocation }),
            let view = map.view(for: user) as? User
        else { return }
        view.orientation(angle: didUpdateHeading.trueHeading * .pi / 180)
    }
    
    final func locationManagerShouldDisplayHeadingCalibration(_: CLLocationManager) -> Bool { true }
    final func locationManagerDidChangeAuthorization(_: CLLocationManager) { }
    final func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) { }
    final func locationManager(_: CLLocationManager, didFailWithError: Error) { }
    final func locationManager(_: CLLocationManager, didFinishDeferredUpdatesWithError: Error?) { }
    
    private func user(span: Bool) {
        UIView
            .animate(withDuration: first ? 0 : 1,
                     delay: 0,
                     options: [.curveEaseInOut, .allowUserInteraction]) { [weak self] in
                guard let map = self?.map else { return }
                
                let center = map.userLocation.location == nil
                    ? map.centerCoordinate
                    : map.userLocation.coordinate.latitude != 0 || map.userLocation.coordinate.longitude != 0
                        ? map.userLocation.coordinate
                        : map.centerCoordinate
                
                if span {
                    var region = MKCoordinateRegion()
                    region.span = .init(latitudeDelta: 0.0015, longitudeDelta: 0.0015)
                    region.center = center
                    map.region = region
                } else {
                    map.centerCoordinate = center
                }
            }
    }
}
