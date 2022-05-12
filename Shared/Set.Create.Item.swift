import Foundation
import CoreLocation

extension Set where Element == Create.Item {
    var distance: CLLocationDistance {
        map(\.route.distance)
            .reduce(0, +)
    }
    
    var duration: TimeInterval {
        map(\.route.expectedTravelTime)
            .reduce(0, +)
    }
}
