import SwiftUI

extension GraphicsContext {
    mutating func compass(session: Session, center: CGPoint) {
        if session.visuals {
            draw(Text(Image(systemName: "n.circle.fill"))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary),
                 at: .init(x: center.x, y: 10))
            
            draw(Text(Image(systemName: "location.north.fill"))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary),
                 at: .init(x: center.x, y: 30))
        }
        
        fill(.init {
            $0.addArc(center: center,
                      radius: session.radius,
                      startAngle: .degrees(0),
                      endAngle: .degrees(360),
                      clockwise: false)
        }, with: .color(white: session.opacity))
        
        fill(.init {
            $0.addArc(center: center,
                      radius: 9,
                      startAngle: .degrees(0),
                      endAngle: .degrees(360),
                      clockwise: false)
        }, with: .color(.white))
        
        translateBy(x: center.x - 15, y: center.y - 30)
        
        drawLayer { layer in
            layer.translateBy(x: 15, y: 30)
            layer.rotate(by: .init(degrees: session.heading))
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
        
        translateBy(x: -center.x + 15, y: -center.y + 30)
    }
}
