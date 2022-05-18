import Foundation
import Offline

extension Navigate {
    final class Control: Mapper {
        init(tiles: Tiles) {
            super.init()
            map.addOverlay(Tiler(tiles: tiles), level: .aboveLabels)
        }
    }
}
