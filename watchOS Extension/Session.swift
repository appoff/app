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
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.allowsBackgroundLocationUpdates = true
    }
    
    deinit {
        print("session gone")
        manager.stopUpdatingHeading()
    }
    
    func start() {
        manager.stopUpdatingHeading()
        manager.startUpdatingHeading()
        
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func tick(date: Date, size: CGSize) {
        opacity = radius < 9 ? 0.1 : opacity + 0.005
        radius = radius < 9 ? 20 : radius - 0.075
    }
    
    func locationManager(_: CLLocationManager, didUpdateHeading: CLHeading) {
        guard
            didUpdateHeading.headingAccuracy >= 0,
            didUpdateHeading.trueHeading >= 0
        else { return }
        heading = didUpdateHeading.trueHeading
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_: CLLocationManager) -> Bool { true }
    func locationManagerDidChangeAuthorization(_: CLLocationManager) { }
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) { }
    func locationManager(_: CLLocationManager, didFailWithError: Error) { }
}
