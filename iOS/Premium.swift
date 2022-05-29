import SwiftUI
import Offline

struct Premium: View {
    let header: Header
    @State private var share = false
    @State private var offload = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button {
                
            } label: {
                HStack {
                    Text("Share")
                        .font(.callout.weight(.medium))
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .regular))
                }
                .frame(width: 130)
                .padding(.vertical, 4)
                .padding(.horizontal, 3)
                .contentShape(Rectangle())
            }
            .buttonStyle(.bordered)
            .foregroundColor(.primary)
            Button {
                offload = true
            } label: {
                HStack {
                    Text("Offload")
                        .font(.callout.weight(.medium))
                    Spacer()
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 16, weight: .regular))
                }
                .frame(width: 130)
                .padding(.vertical, 4)
                .padding(.horizontal, 3)
                .contentShape(Rectangle())
            }
            .buttonStyle(.bordered)
            .foregroundColor(.primary)
            .sheet(isPresented: $offload) {
                Offload(offloader: .init(header: header))
            }
        }
        .symbolRenderingMode(.hierarchical)
    }
}
