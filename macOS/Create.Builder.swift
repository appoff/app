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
        
        private let directions = CurrentValueSubject<_, Never>(Settings.Directions.walking)
        private let route = CurrentValueSubject<_, Never>(Set<Routing>())
        private let points = CurrentValueSubject<_, Never>([MKPointAnnotation]())
        private let overflow = CurrentValueSubject<_, Never>(false)
        private let long = PassthroughSubject<CLLocationCoordinate2D?, Never>()
        private let point = PassthroughSubject<CLLocationCoordinate2D, Never>()
        
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
            
            long
                .debounce(for: .seconds(0.8), scheduler: DispatchQueue.main)
                .compactMap {
                    $0
                }
                .sink { [weak self] location in
                    self?.point.send(location)
                }
                .store(in: &subs)
            
            point
                .sink { [weak self] location in
                    self?.follow.value = false
                    self?.selectedAnnotations
                        .first
                        .map {
                            self?.deselectAnnotation($0, animated: true)
                        }
                    
                    self?.add(coordinate: location, center: false)
                }
                .store(in: &subs)
            
            points
                .map {
                    $0.count > 1
                }
                .removeDuplicates()
                .combineLatest(overflow.removeDuplicates()) {
                    $0 && !$1
                }
                .sink {
                    session.completed.value = $0
                }
                .store(in: &subs)
        }
        
//        func factory(settings: Settings) -> Factory {
//            .init(header: .init(title: sess.value,
//                                origin: points.value.first?.title ?? "",
//                                destination: points.value.last?.title ?? "",
//                                distance: .init(route.value.distance),
//                                duration: .init(route.value.duration)),
//                  points: points.value,
//                  route: route.value,
//                  settings: settings)
//        }
        
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
        
        override func mouseDown(with: NSEvent) {
            super.mouseDown(with: with)
            
            if with.clickCount == 1 {
                long.send(coordinates(event: with))
            }
        }
        
        override func mouseDragged(with: NSEvent) {
            super.mouseDragged(with: with)
            long.send(nil)
        }
        
        override func mouseUp(with: NSEvent) {
            long.send(nil)
            super.mouseUp(with: with)
        }
        
        override func mouseExited(with: NSEvent) {
            super.mouseExited(with: with)
            long.send(nil)
        }
        
        override func rightMouseDragged(with: NSEvent) {
            super.rightMouseDragged(with: with)
        }
        
        override func rightMouseDown(with: NSEvent) {
            super.rightMouseDown(with: with)
            long.send(nil)
        }
        
        override func rightMouseUp(with: NSEvent) {
            long.send(nil)
            
            if with.clickCount == 1 {
                point.send(coordinates(event: with))
            } else {
                super.rightMouseUp(with: with)
            }
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
        
        private func coordinates(event: NSEvent) -> CLLocationCoordinate2D {
            convert(convert(event.locationInWindow, from: nil),
                    toCoordinateFrom: self)
        }
    }
}
