import SwiftUI
import MapKit
import Combine

final class Map: MKMapView, MKMapViewDelegate, UIViewRepresentable {
    var first = true
    let discard = PassthroughSubject<MKPointAnnotation, Never>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        isRotateEnabled = false
        isPitchEnabled = false
        showsUserLocation = true
        pointOfInterestFilter = .excludingAll
        mapType = .standard
        showsTraffic = false
        delegate = self
        
        var region = MKCoordinateRegion()
        region.span = .init(latitudeDelta: 0.005, longitudeDelta: 0.005)
        region.center = userLocation.location == nil
            ? centerCoordinate
            : userLocation.coordinate.latitude != 0 || userLocation.coordinate.longitude != 0
                ? userLocation.coordinate
                : centerCoordinate
        
        setRegion(region, animated: false)
        setUserTrackingMode(.follow, animated: false)
        register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Marker")
        
        print("map")
    }
    
    deinit {
        print("map gone")
    }
    
    func mapView(_: MKMapView, didUpdate: MKUserLocation) {
        guard first else { return }
        first = false
        setUserTrackingMode(.follow, animated: false)
    }
    
    func mapView(_: MKMapView, viewFor: MKAnnotation) -> MKAnnotationView? {
        switch viewFor {
        case is MKUserLocation:
            return nil
        case let point as MKPointAnnotation:
            
            let view = dequeueReusableAnnotationView(withIdentifier: "Marker") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: point, reuseIdentifier: "Marker")
            view.annotation = point
            view.markerTintColor = .label
            view.animatesWhenAdded = true
            view.displayPriority = .required
            view.canShowCallout = true
            
            let button = UIButton(configuration: .plain(), primaryAction: .init { [weak self] _ in
                self?.discard.send(point)
            })
            button.frame = .init(x: 0, y: 0, width: 34, height: 40)
            button.setImage(UIImage(systemName: "xmark.circle.fill")?.applyingSymbolConfiguration(.init(hierarchicalColor: .secondaryLabel))?.applyingSymbolConfiguration(.init(font: .systemFont(ofSize: 16, weight: .light))), for: .normal)
            
            view.leftCalloutAccessoryView = button
            
            return view
        default:
            return nil
        }
    }
    
    func mapView(_: MKMapView, rendererFor: MKOverlay) -> MKOverlayRenderer {
        switch rendererFor {
        case let line as MKMultiPolyline:
            let renderer = MKMultiPolylineRenderer(multiPolyline: line)
            renderer.strokeColor = .secondaryLabel
            return renderer
        default:
            return MKOverlayRenderer(overlay: rendererFor)
        }
    }
    
    func makeUIView(context: Context) -> Map {
        self
    }
    
    func updateUIView(_: Map, context: Context) { }
}
