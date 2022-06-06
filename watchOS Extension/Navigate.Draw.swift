import SwiftUI

extension Navigate {
    struct Draw: View {
        @StateObject private var model = Model()
        
        var body: some View {
            TimelineView(.periodic(from: .now, by: 0.05)) { timeline in
                Canvas { context, size in
                    
                    model.tick(date: timeline.date, size: size)
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    
                    context
                        .fill(.init {
                            $0.addArc(center: center,
                                      radius: model.radius,
                                      startAngle: .degrees(0),
                                      endAngle: .degrees(360),
                                      clockwise: false)
                        }, with: .color(.white.opacity(model.opacity)))
                    
                    context
                        .fill(.init {
                            $0.addArc(center: center,
                                      radius: 10,
                                      startAngle: .degrees(0),
                                      endAngle: .degrees(360),
                                      clockwise: false)
                        }, with: .color(.white))
                }
            }
        }
    }
}
