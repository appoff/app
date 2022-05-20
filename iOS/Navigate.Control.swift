import MapKit
import Offline

extension Navigate {
    final class Control: Mapper {
        @Published var config = false
        @Published var points = false
        let annotations: [(point: MKPointAnnotation, route: Route?)]
        
        init(signature: Signature, tiles: Tiles) {
            annotations = signature.annotations
            
            super.init(editable: false)
            scheme = signature.settings.scheme
            type = signature.settings.map
            interest = signature.settings.interest

            map.addOverlay(Tiler(tiles: tiles), level: .aboveLabels)
            map.addOverlay(signature.polyline, level: .aboveLabels)
            map.addAnnotations(annotations.map(\.point))
        }
    }
}
