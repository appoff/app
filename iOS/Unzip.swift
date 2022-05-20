import SwiftUI
import Offline

struct Unzip: View {
    let session: Session
    let item: Item
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "doc.zipper")
                .font(.system(size: 60, weight: .ultraLight))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)
            
            Text("Loading")
                .font(.title2.weight(.regular))
                .padding(.top)
            
            Text(item.map.title)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: 280)
            
            Spacer()
        }
        .task {
            try? await Task.sleep(nanoseconds: 450_000_000)
            session.selected = nil
            guard let signature = item.signature else { return }
            let tiles = signature.tiles
            
            withAnimation(.easeInOut(duration: 0.5)) {
                session.flow = .navigate(signature, tiles)
            }
        }
    }
}
