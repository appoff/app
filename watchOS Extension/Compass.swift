import SwiftUI

struct Compass: View {
    private let session = Session()
    @Environment(\.scenePhase) private var phase
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TimelineView(.periodic(from: .now, by: 0.05)) { timeline in
                Canvas { context, size in
                    session.tick(date: timeline.date, size: size)
                    context.compass(session: session, center: .init(x: size.width / 2, y: size.height / 2))
                }
            }
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
        .onAppear {
            session.start()
        }
    }
}
