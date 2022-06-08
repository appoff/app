import SwiftUI
import CoreLocation

final class Session: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var visuals = true
    @Published var zoom = Double(10)
    @Published private(set) var radius = Double(20)
    @Published private(set) var opacity = Double(0.1)
    @Published private(set) var heading = Double()
    @Published private(set) var location: CLLocationCoordinate2D?
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.allowsBackgroundLocationUpdates = true
        
        if manager.authorizationStatus == .notDetermined {
            manager.requestAlwaysAuthorization()
        }
        
        manager.stopUpdatingHeading()
        manager.startUpdatingHeading()
        manager.startUpdatingLocation()
    }
    
    deinit {
        manager.stopUpdatingHeading()
        manager.stopUpdatingLocation()
    }
    
    func tick(date: Date, size: CGSize) {
        opacity = radius < 9 ? 0.1 : opacity + 0.005
        radius = radius < 9 ? 20 : radius - 0.075
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) {
        location = didUpdateLocations.last?.coordinate
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
    func locationManager(_: CLLocationManager, didFailWithError: Error) { }
}
