import SwiftUI

extension GraphicsContext {
    mutating func compass(session: Session, size: CGSize, center: CGPoint, active: Bool) {
        if session.visuals {
            draw(Text(Image(systemName: "n.circle.fill"))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary),
                 at: .init(x: center.x, y: 10))
            
            draw(Text(Image(systemName: "s.circle"))
                .font(.system(size: 15, weight: .light))
                .foregroundColor(.primary.opacity(0.3)),
                 at: .init(x: center.x, y: size.height - 10))
            
            draw(Text(Image(systemName: "e.circle"))
                .font(.system(size: 15, weight: .light))
                .foregroundColor(.primary.opacity(0.3)),
                 at: .init(x: size.width - 10, y: center.y))
            
            draw(Text(Image(systemName: "w.circle"))
                .font(.system(size: 15, weight: .light))
                .foregroundColor(.primary.opacity(0.3)),
                 at: .init(x: 10, y: center.y))
            
            if session.location != nil {
                draw(Text(Image(systemName: "location.north.fill"))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary),
                     at: .init(x: center.x, y: 30))
            }
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
                        .init(white: 1, opacity: 1)]),
                                             startPoint: .zero,
                                             endPoint: .init(x: 0, y: 30)))
            }
        }
        
        translateBy(x: -center.x + 15, y: -center.y + 30)
    }
}
