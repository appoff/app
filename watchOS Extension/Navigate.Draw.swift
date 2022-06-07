import SwiftUI

extension Navigate {
    struct Draw: View {
        let session: Session
        
        var body: some View {
            TimelineView(.periodic(from: .now, by: 0.05)) { timeline in
                Canvas { context, size in
                    session.tick(date: timeline.date, size: size)
                    context.compass(session: session, center: .init(x: size.width / 2, y: size.height / 2))
                }
            }
        }
    }
}
