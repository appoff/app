import SwiftUI
import MapKit

final class Map: MKMapView, MKMapViewDelegate, UIViewRepresentable {
    var first = true
//    private var subs = Set<AnyCancellable>()
//    private let dispatch = DispatchQueue(label: "", qos: .utility)
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        isRotateEnabled = false
        isPitchEnabled = false
        showsUserLocation = true
        pointOfInterestFilter = .excludingAll
        mapType = .standard
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
//    
//    func mapView(_: MKMapView, rendererFor: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKPolygonRenderer(overlay: rendererFor)
//        renderer.fillColor = .init(named: "Tile")
//        return renderer
//    }
    
    func makeUIView(context: Context) -> Map {
        self
    }
    
    func updateUIView(_: Map, context: Context) { }
}
