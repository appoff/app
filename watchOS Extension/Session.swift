import SwiftUI
import CoreLocation

final class Session: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var radius = Double(20)
    @Published private(set) var opacity = Double(0.1)
    @Published private(set) var heading = Double()
    private let manager = CLLocationManager()
    
    override init() {
        print("session")
        super.init()
        manager.delegate = self
        manager.stopUpdatingHeading()
        manager.startUpdatingHeading()
        
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    deinit {
        print("session gone")
        manager.stopUpdatingHeading()
    }
    
    func tick(date: Date, size: CGSize) {
        opacity = radius < 10 ? 0.1 : opacity + 0.005
        radius = radius < 10 ? 20 : radius - 0.075
    }
    
    final func locationManager(_: CLLocationManager, didUpdateHeading: CLHeading) {
        guard
            didUpdateHeading.headingAccuracy >= 0,
            didUpdateHeading.trueHeading >= 0
        else { return }
        heading = didUpdateHeading.trueHeading
    }
    
    final func locationManagerShouldDisplayHeadingCalibration(_: CLLocationManager) -> Bool { true }
    final func locationManagerDidChangeAuthorization(_: CLLocationManager) { }
    final func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) { }
    final func locationManager(_: CLLocationManager, didFailWithError: Error) { }
}
