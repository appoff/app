import SwiftUI

extension Compass {
    struct Draw: View {
        let session: Session
        @Environment(\.scenePhase) private var phase
        
        var body: some View {
            TimelineView(.periodic(from: .now, by: phase == .active ? 0.025 : 5)) { timeline in
                Canvas { context, size in
                    if phase == .active {
                        session.tick(date: timeline.date, size: size)
                    }
                    
                    context.compass(session: session,
                                    size: size,
                                    center: .init(x: size.width / 2, y: size.height / 2),
                                    active: phase == .active)
                }
            }
        }
    }
}
