import MapKit

extension Create {
    final class Builder: ObservableObject {
        @Published var search = false
        @Published var cancel = false
        @Published private(set) var points = [MKPointAnnotation]()
        let map = Map()
        private var route = Set<Item>()
        private let tap = UITapGestureRecognizer()
        
        init() {
            map.addGestureRecognizer(tap)
            tap.addTarget(self, action: #selector(tapped))
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
            map.selectAnnotation(point, animated: true)
            directions()
            
            if center {
                map.setCenter(point.coordinate, animated: true)
            }
        }
        
        @objc private func tapped() {
            let point = MKPointAnnotation()
            point.coordinate = map.convert(tap.location(in: map), toCoordinateFrom: nil)
            point.title = "hello"
            point.subtitle = "world"
            add(point: point, center: false)
        }
    }
}


/*
 let request = MKDirections.Request()
 request.transportType = mode == .driving ? .automobile : .walking
 request.source = .init(placemark: .init(coordinate: .init(latitude: path.latitude, longitude: path.longitude), addressDictionary: nil))
 request.destination = .init(placemark: .init(coordinate: .init(latitude: destination.latitude, longitude: destination.longitude), addressDictionary: nil))
 MKDirections(request: request).calculate { [weak self] in
     if $1 == nil, let paths = $0?.routes {
         if let best = paths.sorted(by: { $0.distance < $1.distance && $0.expectedTravelTime < $1.expectedTravelTime }).first {
             let option = Path.Option()
             option.mode = mode
             option.distance = best.distance
             option.duration = best.expectedTravelTime
             option.points = UnsafeBufferPointer(start: best.polyline.points(), count: best.polyline.pointCount).map { ($0.coordinate.latitude, $0.coordinate.longitude) }
             path.options.append(option)
         }
         if app.session.settings.mode == mode {
             self?.line()
             self?.refreshSelecting()
         }
     }
 }
 */
