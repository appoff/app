import SwiftUI
import Offline

struct Navigate: View {
    let schema: Schema
    @StateObject private var session = Session()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Draw(session: session)
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30, weight: .light))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
                    .frame(width: 55, height: 55)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}
