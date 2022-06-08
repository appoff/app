import SwiftUI

struct Compass: View {
    @StateObject private var session = Session()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Draw(session: session)
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 35, weight: .light))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
                    .frame(width: 60, height: 60)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}
