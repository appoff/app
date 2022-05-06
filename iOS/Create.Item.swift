import MapKit

extension Create {
    struct Item: Hashable {
        let origin: MKPointAnnotation
        let destination: MKPointAnnotation
        let route: MKRoute
    }
}
