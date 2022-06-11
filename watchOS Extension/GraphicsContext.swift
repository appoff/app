import SwiftUI

extension GraphicsContext {
    mutating func compass(session: Session, size: CGSize, center: CGPoint, active: Bool) {
        if session.visuals {
            draw(Text(Image(systemName: "n.circle.fill"))
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.primary.opacity(0.6)),
                 at: .init(x: center.x, y: 10))
        }
        
        fill(.init {
            $0.addArc(center: center,
                      radius: session.radius,
                      startAngle: .degrees(0),
                      endAngle: .degrees(360),
                      clockwise: false)
        }, with: .color(white: 1, opacity: session.opacity))
        
        fill(.init {
            $0.addArc(center: center,
                      radius: 9,
                      startAngle: .degrees(0),
                      endAngle: .degrees(360),
                      clockwise: false)
        }, with: .color(.white))
        
        translateBy(x: center.x - 15, y: center.y - 30)
        
        if active {
            drawLayer { layer in
                layer.translateBy(x: 15, y: 30)
                layer.rotate(by: .init(degrees: session.rotation))
                layer.translateBy(x: -15, y: -30)
                layer
                    .fill(.init {
                        $0.move(to: .zero)
                        $0.addLine(to: .init(x: 30, y: 0))
                        $0.addLine(to: .init(x: 24, y: 30))
                        $0.addLine(to: .init(x: 6, y: 30))
                        $0.closeSubpath()
                        
                    }, with: .linearGradient(.init(colors: [
                        .init(white: 1, opacity: 0),
                        .init(white: 1, opacity: 0.5)]),
                                             startPoint: .zero,
                                             endPoint: .init(x: 0, y: 30)))
            }
        }
        
        translateBy(x: -center.x + 15, y: -center.y + 30)
    }
}
