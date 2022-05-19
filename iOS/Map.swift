import SwiftUI
import MapKit
import Combine

final class Map: MKMapView, UIViewRepresentable {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        isPitchEnabled = false
        showsUserLocation = true
        showsTraffic = false
        
        follow(animated: false)
        register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Marker")
        
        print("map")
    }
    
    deinit {
        print("map gone")
    }
    
    func follow(animated: Bool) {
        var region = MKCoordinateRegion()
        region.span = .init(latitudeDelta: 0.005, longitudeDelta: 0.005)
        region.center = userLocation.location == nil
            ? centerCoordinate
            : userLocation.coordinate.latitude != 0 || userLocation.coordinate.longitude != 0
                ? userLocation.coordinate
                : centerCoordinate
        
        setRegion(region, animated: animated)
        setUserTrackingMode(isRotateEnabled ? .followWithHeading : .follow, animated: animated)
    }
    
    func makeUIView(context: Context) -> Map {
        self
    }
    
    func updateUIView(_: Map, context: Context) { }
}
