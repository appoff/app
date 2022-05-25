import SwiftUI
import MapKit
import Combine
import Offline

class Mapper: NSObject, ObservableObject, MKMapViewDelegate, CLLocationManagerDelegate {
    @Published private(set) var color: ColorScheme?
    final var subs = Set<AnyCancellable>()
    let map = Map()
    let geocoder = CLGeocoder()
    let discard = PassthroughSubject<MKPointAnnotation, Never>()
    private var first = true
    private let editable: Bool
    private let position = PassthroughSubject<Void, Never>()
    private let manager = CLLocationManager()
    
    @Published final var type = Settings.Map.standard {
        didSet {
            guard oldValue != type else { return }
            
            switch type {
            case .standard:
                map.mapType = .standard
            case .satellite:
                map.mapType = .satelliteFlyover
            case .hybrid:
                map.mapType = .hybridFlyover
            case .emphasis:
                map.mapType = .mutedStandard
            }
            
            guard editable else { return }
            
            Task {
                await cloud.update(map: type)
            }
        }
    }
    
    @Published final var interest = true {
        didSet {
            guard oldValue != interest else { return }
            
            map.pointOfInterestFilter = interest ? .includingAll : .excludingAll
            
            guard editable else { return }
            
            Task {
                await cloud.update(interest: interest)
            }
        }
    }
    
    @Published final var scheme = Settings.Scheme.auto {
        didSet {
            guard oldValue != scheme else { return }
            
            switch scheme {
            case .auto:
                color = nil
            case .light:
                color = .light
            case .dark:
                color = .dark
            }
            
            guard editable else { return }
            
            Task {
                await cloud.update(scheme: scheme)
            }
        }
    }
    
    @Published final var rotate = true {
        didSet {
            guard oldValue != rotate else { return }
            
            map.isRotateEnabled = rotate
            position.send()
            
            Task {
                await cloud.update(rotate: rotate)
            }
        }
    }
    
    init(editable: Bool) {
        self.editable = editable
        super.init()
        map.delegate = self
        
        cloud
            .first()
            .sink { [weak self] in
                self?.rotate = $0.settings.rotate
            }
            .store(in: &subs)
        
        position
            .debounce(for: .milliseconds(75), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.user(span: false)
                self?.first = false
            }
            .store(in: &subs)
        
        user(span: true)
        
        manager.delegate = self
        manager.stopUpdatingHeading()
        manager.startUpdatingHeading()
    }
    
    deinit {
        manager.stopUpdatingHeading()
    }
    
    final func tracker() {
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
    
    final func locationManager(_: CLLocationManager, didUpdateHeading: CLHeading) {
        guard
            didUpdateHeading.headingAccuracy >= 0,
            didUpdateHeading.trueHeading >= 0,
            let user = map.annotations.first(where: { $0 === map.userLocation }),
            let view = map.view(for: user) as? User
        else { return }
        view.orientation(angle: didUpdateHeading.trueHeading * .pi / 180)
    }
    
    final func locationManagerDidChangeAuthorization(_: CLLocationManager) { }
    final func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) { }
    final func locationManager(_: CLLocationManager, didFailWithError: Error) { }
    
#if os(iOS)
    final func locationManager(_: CLLocationManager, didFinishDeferredUpdatesWithError: Error?) { }
#endif
    
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
