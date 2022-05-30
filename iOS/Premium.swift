import SwiftUI
import Offline

struct Premium: View {
    let session: Session
    let header: Header
    @State private var size = Int()
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                session.flow = .share(header)
            }
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
        .task {
            size = await session.local.size(header: header) ?? 0
        }
        
        if size > 0 {
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
}
