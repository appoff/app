import SwiftUI
import Offline

struct Created: View {
    let session: Session
    let header: Header
    
    var body: some View {
        VStack {
            Spacer()
            Image("Created")
                .foregroundColor(.primary)
                .padding(.top, 40)
            Text("Ready")
                .font(.title2.weight(.regular))
            Text(header.title)
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
                    .font(.body.weight(.bold))
                    .foregroundColor(.primary)
                    .padding()
                    .contentShape(Rectangle())
            }
            Spacer()
        }
    }
}
