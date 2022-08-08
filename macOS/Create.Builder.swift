import MapKit
import Combine
import Offline

extension Create {
    final class Builder: Map {
//        @Published var search = false
//        @Published var cancel = false
//        @Published var options = false
//        @Published var config = false
//        @Published var help = false
//        @Published var title = "New map"
//        @Published private(set) var overflow = false
//        @Published private(set) var points = [MKPointAnnotation]()
//        @Published private(set) var route = Set<Routing>()
//        private let long = UILongPressGestureRecognizer()
        
        let directions = CurrentValueSubject<_, Never>(Settings.Directions.walking)
        let route = CurrentValueSubject<_, Never>(Set<Routing>())
        let points = CurrentValueSubject<_, Never>([MKPointAnnotation]())
        let title = CurrentValueSubject<_, Never>("New map")
        
        required init?(coder: NSCoder) { nil }
        init(session: Session) {
            super.init(session: session, editable: true)
            directions
                .removeDuplicates()
                .sink { [weak self] directions in
                    self?.route.value = []
//                    self?.trace()
                    
                    Task {
                        await cloud.update(directions: directions)
                    }
                }
                .store(in: &subs)
            
            discard
                .sink { [weak self] in
                    self?.follow.value = false
                    self?.remove(discarded: [$0])
                }
                .store(in: &subs)
            
            cloud
                .first()
                .sink { [weak self] in
                    self?.type.value = $0.settings.map
                    self?.interest.value = $0.settings.interest
                    self?.scheme.value = $0.settings.scheme
                    self?.directions.value = $0.settings.directions
                }
                .store(in: &subs)
        }
        
        func factory(settings: Settings) -> Factory {
            .init(header: .init(title: title.value,
                                origin: points.value.first?.title ?? "",
                                destination: points.value.last?.title ?? "",
                                distance: .init(route.value.distance),
                                duration: .init(route.value.duration)),
                  points: points.value,
                  route: route.value,
                  settings: settings)
        }
        
        func current() {
            add(coordinate: userLocation.location == nil ? centerCoordinate : userLocation.location!.coordinate,
                center: true)
        }
        
        @MainActor func selected(completion: MKLocalSearchCompletion) async {
            guard
                let response = try? await MKLocalSearch(request: .init(completion: completion)).start(),
                let item = response.mapItems.first
            else { return }
            let point = MKPointAnnotation()
            point.coordinate = item.placemark.coordinate
            point.title = item.name
            point.subtitle = item.placemark.responds(to: #selector(getter: MKAnnotation.title))
                ? item.placemark.title
                : item.placemark.responds(to: #selector(getter: MKAnnotation.subtitle))
                    ? item.placemark.subtitle
                    : ""
            sourroundings(coordinate: point.coordinate)
            add(point: point, center: true)
        }
        
        private func trace() {
//            var pairs = [(MKPointAnnotation, MKPointAnnotation)]()
//            _ = points.reduce(nil) { previous, current -> MKPointAnnotation? in
//                if let previous = previous {
//                    if !route.contains(where: { $0.origin == previous && $0.destination == current }) {
//                        pairs.append((previous, current))
//                    }
//                }
//                return current
//            }
//
//            Task { [pairs] in
//                await make(pairs: pairs)
//            }
        }
        
        private func make(pairs: [(MKPointAnnotation, MKPointAnnotation)]) async {
            for pair in pairs {
                let request = MKDirections.Request()
                
                switch directions.value {
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
                    }) else { continue }

                route.value.insert(.init(origin: pair.0, destination: pair.1, route: response))
            }
            
            await MainActor
                .run {
                    removeOverlays(overlays)
                    addOverlay(MKMultiPolyline(route.value.map(\.route.polyline)),
                               level: .aboveLabels)
                }
        }
        
        private func add(point: MKPointAnnotation, center: Bool) {
            points.value.append(point)
            addAnnotation(point)
            
            validate()
            
            if center {
                setCenter(point.coordinate, animated: true)
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
        
        private func add(coordinate: CLLocationCoordinate2D, center: Bool) {
            sourroundings(coordinate: coordinate)
            
            let point = MKPointAnnotation()
            point.coordinate = coordinate
            
            add(point: point, center: center)
            
            Task {
                await geocode(point: point)
            }
        }
        
        private func sourroundings(coordinate: CLLocationCoordinate2D) {
//            remove(discarded: points
//                .filter {
//                    $0.coordinate.delta(other: coordinate) < 0.0000006
//                })
        }
        
        private func remove(discarded: [MKPointAnnotation]) {
//            discarded
//                .forEach { discard in
//                    _ = points
//                        .firstIndex(of: discard)
//                        .map {
//                            points.remove(at: $0)
//                        }
//
//                    route = route
//                        .filter {
//                            $0.origin != discard && $0.destination != discard
//                        }
//
//                    map.removeAnnotation(discard)
//                }
//
//            validate()
//
//            trace()
        }
        
        private func validate() {
//            guard points.count > 1 else {
//                overflow = false
//                return
//            }
//
//            let rect = points
//                .map(\.coordinate)
//                .rect
//
//            overflow = rect.width + rect.height > limit
        }
        
//        @objc private func pressed() {
//            guard long.state == .began else { return }
//            map.follow = false
//            long.isEnabled = false
//
//            map
//                .selectedAnnotations
//                .first
//                .map {
//                    map.deselectAnnotation($0, animated: true)
//                }
//
//            add(coordinate: map.convert(long.location(in: map), toCoordinateFrom: map), center: false)
//
//            long.isEnabled = true
//        }
    }
}
