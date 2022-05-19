import MapKit
import Offline

extension Create {
    final class Builder: Mapper {
        @Published var search = false
        @Published var cancel = false
        @Published var options = false
        @Published var config = false
        @Published var title = "New map"
        @Published private(set) var points = [MKPointAnnotation]()
        @Published private(set) var route = Set<Item>()
        private let long = UILongPressGestureRecognizer()
        
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
        
        init() {
            super.init(editable: true)
            map.addGestureRecognizer(long)
            long.addTarget(self, action: #selector(pressed))
            
            discard
                .sink { [weak self] in
                    self?.remove(discarded: [$0])
                }
                .store(in: &subs)
            
            cloud
                .first()
                .sink { [weak self] in
                    self?.type = $0.settings.map
                    self?.interest = $0.settings.interest
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
        
        @MainActor func selected(completion: MKLocalSearchCompletion) async {
            guard
                let response = try? await MKLocalSearch(request: .init(completion: completion)).start(),
                let item = response.mapItems.first
            else { return }
            let point = MKPointAnnotation()
            point.coordinate = item.placemark.coordinate
            point.title = item.placemark.responds(to: #selector(getter: MKAnnotation.title)) ? item.placemark.title : item.name
            point.subtitle = item.placemark.responds(to: #selector(getter: MKAnnotation.subtitle)) ? item.placemark.subtitle : ""
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
                let location = try? await geocoder.reverseGeocodeLocation(.init(
                    latitude: point.coordinate.latitude,
                    longitude: point.coordinate.longitude))
                    .first
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
