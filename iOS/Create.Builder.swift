import SwiftUI
import MapKit
import Combine
import Offline

extension Create {
    final class Builder: ObservableObject {
        @Published var search = false
        @Published var cancel = false
        @Published var title = "New map"
        
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
        
        @Published var rotate = false {
            didSet {
                guard oldValue != rotate else { return }
                
                map.isRotateEnabled = rotate
                map.follow(animated: true)
                
                Task {
                    await cloud.update(rotate: rotate)
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
        
        @Published var directions = Settings.Directions.walking {
            didSet {
                guard oldValue != directions else { return }
                
                route = []
                trace()
                
                Task {
                    await cloud.update(directions: directions)
                }
            }
        }
        
        @Published private(set) var color: ColorScheme?
        @Published private(set) var points = [MKPointAnnotation]()
        @Published private(set) var route = Set<Item>()
        let map = Map()
        private var subs = Set<AnyCancellable>()
        private let long = UILongPressGestureRecognizer()
        private let geocoder = CLGeocoder()
        
        init() {
            map.addGestureRecognizer(long)
            long.addTarget(self, action: #selector(pressed))
            map
                .discard
                .sink { [weak self] in
                    self?.remove(discarded: [$0])
                }
                .store(in: &subs)
            
            cloud
                .first()
                .sink { [weak self] in
                    self?.type = $0.settings.map
                    self?.interest = $0.settings.interest
                    self?.rotate = $0.settings.rotate
                    self?.scheme = $0.settings.scheme
                    self?.directions = $0.settings.directions
                }
                .store(in: &subs)
        }
        
        func factory(settings: Settings) -> Factory {
            .init(map: .init(title: title,
                             origin: points.first?.title ?? "",
                             destination: points.last?.title ?? "",
                             distance: .init(route.distance),
                             duration: .init(route.duration)),
                  points: points,
                  route: route.map(\.route),
                  settings: settings)
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
        
        @MainActor func selected(completion: MKLocalSearchCompletion) async {
            guard
                let response = try? await MKLocalSearch(request: .init(completion: completion)).start(),
                let placemark = response.mapItems.first?.placemark
            else { return }
            let point = MKPointAnnotation()
            point.coordinate = placemark.coordinate
            point.title = placemark.title
            point.subtitle = placemark.subtitle
            add(point: point, center: true)
        }
        
        private func trace() {
            var pairs = [(MKPointAnnotation, MKPointAnnotation)]()
            _ = points.reduce(nil) { previous, current -> MKPointAnnotation? in
                if let previous = previous {
                    if !route.contains(where: { $0.origin == previous && $0.destination == current }) {
                        pairs.append((previous, current))
                    }
                }
                return current
            }
            
            Task { [pairs] in
                await make(pairs: pairs)
            }
        }
        
        private func make(pairs: [(MKPointAnnotation, MKPointAnnotation)]) async {
            for pair in pairs {
                let request = MKDirections.Request()
                
                switch directions {
                case .walking:
                    request.transportType = .walking
                case .driving:
                    request.transportType = .automobile
                }
                
                request.source = .init(placemark: .init(coordinate: pair.0.coordinate))
                request.destination = .init(placemark: .init(coordinate: pair.1.coordinate))
                
                guard let response = try? await MKDirections(request: request)
                    .calculate()
                    .routes
                    .min(by: { a, b in
                        a.expectedTravelTime < b.expectedTravelTime
                    })  else { continue }

                route.insert(.init(origin: pair.0, destination: pair.1, route: response))
            }
            
            await MainActor
                .run {
                    map.removeOverlays(map.overlays)
                    map.addOverlay(MKMultiPolyline(route.map(\.route.polyline)), level: .aboveLabels)
                }
        }
        
        private func add(point: MKPointAnnotation, center: Bool) {
            points.append(point)
            map.addAnnotation(point)
            
            if center {
                map.setCenter(point.coordinate, animated: true)
            }
            
            trace()
        }
        
        private func geocode(point: MKPointAnnotation) async {
            guard
                let location = try? await geocoder.reverseGeocodeLocation(.init(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)).first
            else { return }
            point.title = location.name
            
            if let thoroughfare = location.thoroughfare {
                point.subtitle = thoroughfare
                
                if let subThoroughfare = location.subThoroughfare,
                   !subThoroughfare.isEmpty {
                    point.subtitle! += " " + subThoroughfare
                    
                    if point.title?.lowercased() == point.subtitle?.lowercased() {
                        if let locality = location.locality,
                           !locality.isEmpty {
                            point.subtitle = locality
                        } else {
                            point.subtitle = location.subLocality
                            ?? location.postalCode
                            ?? location.areasOfInterest?.first
                            ?? location.subAdministrativeArea
                            ?? location.administrativeArea
                        }
                    }
                }
            }
        }
        
        private func remove(discarded: [MKPointAnnotation]) {
            discarded
                .forEach { discard in
                    _ = points
                        .firstIndex(of: discard)
                        .map {
                            points.remove(at: $0)
                        }
                    
                    route = route
                        .filter {
                            $0.origin != discard && $0.destination != discard
                        }
                    
                    map.removeAnnotation(discard)
                }
            
            trace()
        }
        
        @objc private func pressed() {
            guard long.state == .began else { return }
            long.isEnabled = false
            
            map
                .selectedAnnotations
                .first
                .map {
                    map.deselectAnnotation($0, animated: true)
                }
            
            let coordinate = map.convert(long.location(in: map), toCoordinateFrom: nil)
            remove(discarded: points
                .filter { point in
                    abs(point.coordinate.latitude - coordinate.latitude) + abs(point.coordinate.longitude - coordinate.longitude) < 0.003
                })
            
            let point = MKPointAnnotation()
            point.coordinate = coordinate
            
            add(point: point, center: false)
            
            Task {
                await geocode(point: point)
            }
            
            long.isEnabled = true
        }
    }
}
