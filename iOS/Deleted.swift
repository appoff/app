import SwiftUI
import Offline

struct Deleted: View {
    let session: Session
    let map: Offline.Map
    
    var body: some View {
        VStack {
            Spacer()
            Image("Deleted")
                .foregroundColor(.primary)
            Text("Deleted")
                .font(.title.weight(.medium))
                .padding(.top)
            Text(map.title)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: 280)
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    session.flow = .main
                }
            } label: {
                Text("Continue")
                    .font(.callout)
                    .foregroundColor(.primary)
                    .padding()
                    .contentShape(Rectangle())
            }
            Spacer()
        }
        .task {
            session.selected = nil
            await cloud.delete(map: map)
            session.local.delete(map: map)
        }
    }
}
