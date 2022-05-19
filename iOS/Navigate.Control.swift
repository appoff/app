import MapKit
import Offline

extension Navigate {
    final class Control: Mapper {
        @Published var config = false
        @Published var points = false
        let annotations: [MKPointAnnotation]
        let route: [Tiles.Route]
        
        init(tiles: Tiles) {
            annotations = tiles.annotations
            route = tiles.route
            
            super.init(editable: false)
            scheme = tiles.settings.scheme
            type = tiles.settings.map
            interest = tiles.settings.interest

            map.addOverlay(Tiler(tiles: tiles), level: .aboveLabels)
            map.addOverlay(tiles.polyline, level: .aboveLabels)
            map.addAnnotations(annotations)
        }
    }
}
