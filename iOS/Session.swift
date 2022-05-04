import Foundation
import CoreLocation

final class Session: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var authorized = false
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func locationManagerDidChangeAuthorization(_: CLLocationManager) {
        authorized = manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) { }
    func locationManager(_: CLLocationManager, didFailWithError: Error) { }
    
    #if os(iOS)
    func locationManager(_: CLLocationManager, didFinishDeferredUpdatesWithError: Error?) { }
    #endif
}
