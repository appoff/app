import SwiftUI
import MapKit

final class Map: MKMapView, MKMapViewDelegate, UIViewRepresentable {
    private var first = true
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
    }
    
    func mapView(_: MKMapView, didUpdate: MKUserLocation) {
        guard first else { return }
        first = false
        setUserTrackingMode(.follow, animated: true)
    }
//    
//    func mapView(_: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
////        status.follow = mode == .follow
//    }
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
