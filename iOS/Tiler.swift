import MapKit

private let size = 512

final class Tiler: MKTileOverlay {
    init() {
        super.init(urlTemplate: nil)
        tileSize = .init(width: size, height: size)
    }
    
//    override func loadTile(at: MKTileOverlayPath, result: @escaping(Data?, Error?) -> Void) {
////        cart.tile(at.x, at.y, at.z) { [weak self] in
////            result($0 ?? self?.fallback, nil)
////        }
//    }
    
    override func loadTile(at path: MKTileOverlayPath) async throws -> Data {
        .init()
    }
}
