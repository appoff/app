import MapKit
import Offline

private let size = 512

final class Tiler: MKTileOverlay {
    private let tiles: Tiles
    
    init(tiles: Tiles) {
        self.tiles = tiles
        super.init(urlTemplate: nil)
        tileSize = .init(width: size, height: size)
    }
    
//    override func loadTile(at: MKTileOverlayPath, result: @escaping(Data?, Error?) -> Void) {
////        cart.tile(at.x, at.y, at.z) { [weak self] in
////            result($0 ?? self?.fallback, nil)
////        }
//    }
    
    override func loadTile(at: MKTileOverlayPath) async throws -> Data {
        await Task.detached(priority: .utility) {
            self.tiles[at.x, at.y, at.z]
        }
        .value ?? .init()
    }
}
