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
                .font(.title2.weight(.regular))
                .padding(.top)
            Text(map.title)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: 280)
            Spacer()
            Button {
                session.selected = nil
                withAnimation(.easeInOut(duration: 0.3)) {
                    session.flow = .main
                }
            } label: {
                Text("Continue")
                    .font(.body.weight(.bold))
                    .foregroundColor(.primary)
                    .padding()
                    .contentShape(Rectangle())
            }
            Spacer()
        }
        .task {
            try? await Task.sleep(nanoseconds: 450_000_000)
            await cloud.delete(map: map)
            session.local.delete(map: map)
        }
    }
}