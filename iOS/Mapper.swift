import SwiftUI
import MapKit
import Combine
import Offline

class Mapper: ObservableObject {
    @Published private(set) var color: ColorScheme?
    var subs = Set<AnyCancellable>()
    let map = Map()
    let geocoder = CLGeocoder()
    
    @Published var type = Settings.Map.standard {
        didSet {
            guard oldValue != type else { return }
            
            switch type {
            case .standard:
                map.mapType = .standard
            case .satellite:
                map.mapType = .satelliteFlyover
            case .hybrid:
                map.mapType = .hybridFlyover
            case .emphasis:
                map.mapType = .mutedStandard
            }
            
            Task {
                await cloud.update(map: type)
            }
        }
    }
    
    @Published var interest = true {
        didSet {
            guard oldValue != interest else { return }
            
            map.pointOfInterestFilter = interest ? .includingAll : .excludingAll
            
            Task {
                await cloud.update(interest: interest)
            }
        }
    }
    
    @Published var scheme = Settings.Scheme.auto {
        didSet {
            guard oldValue != scheme else { return }
            
            switch scheme {
            case .auto:
                color = nil
            case .light:
                color = .light
            case .dark:
                color = .dark
            }
            
            Task {
                await cloud.update(scheme: scheme)
            }
        }
    }
    
    init() {
        cloud
            .first()
            .sink { [weak self] in
                self?.type = $0.settings.map
                self?.interest = $0.settings.interest
                self?.scheme = $0.settings.scheme
            }
            .store(in: &subs)
    }
    
    func tracker() {
        let manager = CLLocationManager()
        switch manager.authorizationStatus {
        case .denied, .restricted:
            UIApplication.shared.settings()
        case .notDetermined:
            map.first = true
            manager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            map.follow(animated: true)
        @unknown default:
            break
        }
    }
}
