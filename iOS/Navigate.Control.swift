import MapKit
import Offline

extension Navigate {
    final class Control: Mapper {
        @Published var config = false
        @Published var points = false
        let annotations: [(point: MKPointAnnotation, route: Route?)]
        
        init(schema: Schema, bufferer: Bufferer) {
            annotations = schema.annotations
            
            super.init(editable: false)
            scheme = schema.settings.scheme
            type = schema.settings.map
            interest = schema.settings.interest

            map.addOverlay(Tiler(bufferer: bufferer), level: .aboveLabels)
            map.addOverlay(schema.polyline, level: .aboveLabels)
            map.addAnnotations(annotations.map(\.point))
        }
    }
}
