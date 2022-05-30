import SwiftUI
import Offline

struct Premium: View {
    let session: Session
    let header: Header
    
    var body: some View {
        Button {
            
        } label: {
            HStack {
                Text("Share")
                    .font(.callout.weight(.medium))
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .regular))
                    .symbolRenderingMode(.hierarchical)
            }
            .frame(width: 130)
            .padding(.vertical, 4)
            .padding(.horizontal, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .foregroundColor(.primary)
        .padding(.bottom, 20)
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                session.flow = .offload(header)
            }
        } label: {
            HStack {
                Text("Offload")
                    .font(.callout.weight(.medium))
                Spacer()
                Image(systemName: "icloud.and.arrow.up")
                    .font(.system(size: 16, weight: .regular))
                    .symbolRenderingMode(.hierarchical)
            }
            .frame(width: 130)
            .padding(.vertical, 4)
            .padding(.horizontal, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .foregroundColor(.primary)
    }
}
