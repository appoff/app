import MapKit
import Coffee
import Combine
import Offline

class Map: MKMapView, MKMapViewDelegate, CLLocationManagerDelegate {
    final var follow = true
    final var subs = Set<AnyCancellable>()
    let geocoder = CLGeocoder()
    let discard = PassthroughSubject<MKPointAnnotation, Never>()
    let type = CurrentValueSubject<_, Never>(Settings.Map.standard)
    let scheme = CurrentValueSubject<_, Never>(Settings.Scheme.auto)
    let interest = CurrentValueSubject<_, Never>(true)
    let rotate = CurrentValueSubject<_, Never>(true)
    private var first = true
    private let editable: Bool
    private let position = PassthroughSubject<Void, Never>()
    private let manager = CLLocationManager()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, editable: Bool) {
        self.editable = editable
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
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
                    self?.appearance = nil
                case .light:
                    self?.appearance = .init(named: .aqua)
                case .dark:
                    self?.appearance = .init(named: .darkAqua)
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
                self?.user(span: false)
                self?.first = false
            }
            .store(in: &subs)
        
        session
            .follow
            .sink { [weak self] in
                 self?
                     .selectedAnnotations
                     .first
                     .map {
                         self?.deselectAnnotation($0, animated: true)
                     }

                switch self?.manager.authorizationStatus {
                case .denied, .restricted:
                    NSWorkspace
                        .shared
                        .open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Offline_LocationServices")!)
                case .notDetermined:
                    self?.first = true
                    self?.manager.requestAlwaysAuthorization()
                case .authorizedAlways, .authorizedWhenInUse:
                    self?.user(span: true)
                    self?.follow = true
                default:
                    break
                }
            }
            .store(in: &subs)
        
        user(span: true)
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    final func mapView(_: MKMapView, didUpdate: MKUserLocation) {
        guard
            follow,
            let delta = didUpdate.location.map({ $0.coordinate.delta(other: centerCoordinate) }),
            delta > 0.000000015
        else { return }
        position.send()
    }
    
    final func mapView(_: MKMapView, viewFor: MKAnnotation) -> MKAnnotationView? {
        switch viewFor {
        case let user as MKUserLocation:
            let view = dequeueReusableAnnotationView(withIdentifier: "User") as? User ?? User()
            view.annotation = user
            return view
        case let point as MKPointAnnotation:
            let view = dequeueReusableAnnotationView(withIdentifier: "Marker") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: point, reuseIdentifier: "Marker")
            view.glyphImage = .init(named: "Logo")
            view.annotation = point
            view.markerTintColor = .labelColor
            view.animatesWhenAdded = true
            view.displayPriority = .required
            view.canShowCallout = true
            
            if editable {
                let button = Control.Symbol(symbol: "xmark", size: 14, background: false)
                button.toolTip = "Remove marker"
                button
                    .click
                    .sink { [weak self] in
                        self?.discard.send(point)
                    }
                    .store(in: &subs)
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
            liner.strokeColor = .labelColor
            return liner
        default:
            return MKTileOverlayRenderer(tileOverlay: rendererFor as! Tiler)
        }
    }
    
    func mapView(_: MKMapView, didSelect: MKAnnotationView) {
        follow = false
    }
    
    final func locationManagerDidChangeAuthorization(_: CLLocationManager) { }
    final func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) { }
    final func locationManager(_: CLLocationManager, didFailWithError: Error) { }
    final func locationManager(_: CLLocationManager, didFinishDeferredUpdatesWithError: Error?) { }
    
    private func user(span: Bool) {
        NSAnimationContext
            .runAnimationGroup {
                $0.duration = first ? 0 : 1
                let center = userLocation.location == nil
                ? centerCoordinate
                : userLocation.coordinate.latitude != 0 || userLocation.coordinate.longitude != 0
                ? userLocation.coordinate
                : centerCoordinate
                
                if span {
                    var region = MKCoordinateRegion()
                    region.span = .init(latitudeDelta: 0.0015, longitudeDelta: 0.0015)
                    region.center = center
                    self.region = region
                } else {
                    centerCoordinate = center
                }
            }
    }
}
