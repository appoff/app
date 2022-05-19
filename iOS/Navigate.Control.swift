import Foundation
import Offline

extension Navigate {
    final class Control: Mapper {
        init(tiles: Tiles) {
            super.init(editable: false)
            scheme = tiles.settings.scheme
            type = tiles.settings.map
            interest = tiles.settings.interest
            
            map.addOverlay(Tiler(tiles: tiles), level: .aboveLabels)
        }
    }
}
