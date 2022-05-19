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
    
    override func loadTile(at: MKTileOverlayPath) async throws -> Data {
        tiles[at.x, at.y, at.z] ?? .init()
    }
}
