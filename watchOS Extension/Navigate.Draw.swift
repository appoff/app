import SwiftUI

extension Navigate {
    struct Draw: View {
        let session: Session
        
        var body: some View {
            TimelineView(.periodic(from: .now, by: 0.05)) { timeline in
                Canvas { context, size in
                    session.tick(date: timeline.date, size: size)
                    
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    
                    context
                        .fill(.init {
                            $0.addArc(center: center,
                                      radius: session.radius,
                                      startAngle: .degrees(0),
                                      endAngle: .degrees(360),
                                      clockwise: false)
                        }, with: .color(.white.opacity(session.opacity)))
                    
                    context
                        .fill(.init {
                            $0.addArc(center: center,
                                      radius: 10,
                                      startAngle: .degrees(0),
                                      endAngle: .degrees(360),
                                      clockwise: false)
                        }, with: .color(.white))

                    context.translateBy(x: center.x, y: center.y)
                    context
                        .drawLayer { layer in
                            layer.rotate(by: .degrees(45))
                            layer
                                .fill(.init {
                                    $0.move(to: .init(x: -15, y: -15))
                                    $0.addLine(to: .init(x: 15, y: -15))
                                    $0.addLine(to: .init(x: 9, y: 15))
                                    $0.addLine(to: .init(x: -9, y: 15))
                                    $0.closeSubpath()
                                }, with: .linearGradient(.init(colors: [
                                    .init(white: 1, opacity: 0),
                                    .init(white: 1, opacity: 1)]),
                                                         startPoint: .init(x: 0, y: -15),
                                                         endPoint: .init(x: 0, y: 15)))
                        }
                    
                    context.translateBy(x: -center.x, y: -center.y)
                    
                    /*
                     let gradient = CAGradientLayer()
                     gradient.startPoint = .init(x: 0.5, y: 1)
                     gradient.endPoint = .init(x: 0.5, y: 0)
                     gradient.locations = [0, 1]
                     gradient.frame = .init(x: 0, y: 0, width: 30, height: 30)
                     gradient.colors = [CGColor(gray: 0, alpha: 1), CGColor(gray: 0, alpha: 0)]
                     
                     let heading = CAShapeLayer()
                     heading.frame = .init(x: -4, y: -4, width: 30, height: 30)
                     heading.anchorPoint = .init(x: 0.5, y: 1)
                     heading.path = { path in
                         path.move(to: .zero)
                         path.addLine(to: .init(x: 30, y: 0))
                         path.addLine(to: .init(x: 24, y: 30))
                         path.addLine(to: .init(x: 6, y: 30))
                         path.closeSubpath()
                         return path
                     } (CGMutablePath())
                     heading.mask = gradient
                     layer.addSublayer(heading)
                     self.heading = heading
                     */
                }
            }
        }
    }
}
