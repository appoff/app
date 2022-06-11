import SwiftUI

extension Compass {
    struct Draw: View {
        let session: Session
        @Environment(\.scenePhase) private var phase
        
        var body: some View {
            TimelineView(.animation(minimumInterval: 0.05, paused: phase != .active)) { timeline in
                Canvas { context, size in
                    if phase == .active {
                        session.tick(date: timeline.date, size: size)
                    }
                    
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    
                    context
                        .draw(Text(Image(systemName: "s.circle"))
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.primary.opacity(0.5)),
                         at: .init(x: center.x, y: size.height - 10))
                    
                    context
                        .draw(Text(Image(systemName: "e.circle"))
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.primary.opacity(0.5)),
                         at: .init(x: size.width - 10, y: center.y))
                    
                    context
                        .draw(Text(Image(systemName: "w.circle"))
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.primary.opacity(0.5)),
                         at: .init(x: 10, y: center.y))
                    
                    context.compass(session: session,
                                    size: size,
                                    center: center,
                                    active: phase == .active)
                }
            }
        }
    }
}
