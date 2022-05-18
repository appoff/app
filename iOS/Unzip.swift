import SwiftUI
import Offline

struct Unzip: View {
    let session: Session
    let data: Data
    
    var body: some View {
        VStack {
            Image(systemName: "doc.zipper")
                .font(.system(size: 40, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
        }
        .task {
            session.selected = nil
            Task.detached(priority: .utility) { [data] in
                var data = data
                let tiles = Tiles(data: &data)
                
                await MainActor.run {
                    session.flow = .navigate(tiles)
                }
            }
        }
    }
}
