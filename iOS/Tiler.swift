import MapKit
import Offline

private let size = 512

final class Tiler: MKTileOverlay {
    private let bufferer: Bufferer
    
    init(bufferer: Bufferer) {
        self.bufferer = bufferer
        super.init(urlTemplate: nil)
        tileSize = .init(width: size, height: size)
    }
    
    override func loadTile(at: MKTileOverlayPath) async throws -> Data {
        try await Task
            .detached(priority: .utility) { [weak self] in
                try await self?.bufferer.load(at: at) ?? .init()
            }
            .value
    }
}
