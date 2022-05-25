import MapKit
import Offline

extension Navigate {
    final class Control: Mapper {
        @Published var config = false
        @Published var points = false
        let annotations: [(point: MKPointAnnotation, route: Route?)]
        private let polyline: MKMultiPolyline
        
        var directions = true {
            didSet {
                guard oldValue != directions else { return }
                overlays()
            }
        }
        
        init(schema: Schema, bufferer: Bufferer) {
            annotations = schema.annotations
            polyline = schema.polyline
            
            super.init(editable: false)
            scheme = schema.settings.scheme
            type = schema.settings.map
            interest = schema.settings.interest
            
            map.addOverlay(Tiler(bufferer: bufferer), level: .aboveLabels)
            map.addAnnotations(annotations.map(\.point))
            overlays()
        }
        
        private func overlays() {
            if directions {
                map.addOverlay(polyline, level: .aboveLabels)
            } else {
                map.removeOverlay(polyline)
            }
        }
    }
}
