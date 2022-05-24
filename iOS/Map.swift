import SwiftUI
import MapKit

final class Map: MKMapView, UIViewRepresentable {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        isPitchEnabled = false
        showsUserLocation = true
        showsTraffic = false
        register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Marker")
        
        print("map")
    }
    
    deinit {
        print("map gone")
    }
    
    func makeUIView(context: Context) -> Map {
        self
    }
    
    func updateUIView(_: Map, context: Context) { }
}
