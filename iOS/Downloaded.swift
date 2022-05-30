import SwiftUI
import Offline

struct Downloaded: View {
    let session: Session
    let header: Header
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "icloud.and.arrow.down")
                .font(.system(size: 60, weight: .ultraLight))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tertiary)
            Text("Downloaded")
                .font(.title2.weight(.regular))
                .padding(.top)
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
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)
                    .padding()
                    .contentShape(Rectangle())
            }
            
            Spacer()
        }
    }
}
