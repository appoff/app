import MapKit

extension Create {
    final class Builder: ObservableObject {
        @Published var search = false
        @Published var cancel = false
        @Published private(set) var points = [MKPointAnnotation]()
        let map = Map()
        private var route = Set<Item>()
        private let long = UILongPressGestureRecognizer()
        private let geocoder = CLGeocoder()
        
        init() {
            map.addGestureRecognizer(long)
            long.addTarget(self, action: #selector(pressed))
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
                map.setUserTrackingMode(.follow, animated: true)
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
        
        private func directions() {
            route = route
                .filter {
                    points.contains($0.origin) && points.contains($0.destination)
                }
            
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
                request.transportType = .walking
                request.source = .init(placemark: .init(coordinate: pair.0.coordinate))
                request.destination = .init(placemark: .init(coordinate: pair.1.coordinate))
                
                guard let response = try? await MKDirections(request: request).calculate().routes.first else { continue }

                route.insert(.init(origin: pair.0, destination: pair.1, route: response))
            }
            
            await MainActor
                .run {
                    map.removeOverlays(map.overlays.filter { $0 is MKMultiPolyline })
                    map.addOverlay(MKMultiPolyline(route.map(\.route.polyline)), level: .aboveLabels)
                }
        }
        
        private func add(point: MKPointAnnotation, center: Bool) {
            points.append(point)
            map.addAnnotation(point)
            
            if center {
                map.setCenter(point.coordinate, animated: true)
                map.selectAnnotation(point, animated: true)
            }
            
            directions()
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
                    
                    if let locality = location.locality,
                       !locality.isEmpty {
                        point.subtitle! += " " + locality
                    }
                }
            }
        }
        
        @objc private func pressed() {
            let coordinate = map.convert(long.location(in: map), toCoordinateFrom: nil)
            
//            guard points.contains(where: <#T##(MKPointAnnotation) throws -> Bool#>)
            
            let point = MKPointAnnotation()
            point.coordinate = coordinate
            
            add(point: point, center: false)
            
            Task {
                await geocode(point: point)
            }
        }
    }
}
