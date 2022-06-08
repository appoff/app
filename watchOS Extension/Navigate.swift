import SwiftUI
import Offline

struct Navigate: View {
    let schema: Schema
    @StateObject private var session = Session()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Button {
                session.visuals.toggle()
            } label: {
                Rectangle()
                    .fill(.black)
                    .frame(maxWidth: .greatestFiniteMagnitude, maxHeight: .greatestFiniteMagnitude)
            }
            .buttonStyle(.plain)
            .focusable()
            .digitalCrownRotation($session.zoom,
                                  from: 1,
                                  through: 100,
                                  by: 1,
                                  sensitivity: .low,
                                  isContinuous: false,
                                  isHapticFeedbackEnabled: true)
            
            Draw(session: session, annotations: schema.annotations)
                .allowsHitTesting(false)
            
            if session.visuals {
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
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}
