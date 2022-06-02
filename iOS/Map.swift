import SwiftUI
import MapKit

final class Map: MKMapView, UIViewRepresentable {
    var follow = true
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        isPitchEnabled = false
        showsUserLocation = true
        showsTraffic = false
        userTrackingMode = .none
        register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Marker")
    }
    
    func makeUIView(context: Context) -> Map {
        self
    }
    
    func updateUIView(_: Map, context: Context) { }
    
    override func touchesBegan(_: Set<UITouch>, with: UIEvent?) {
        follow = false
    }
}
