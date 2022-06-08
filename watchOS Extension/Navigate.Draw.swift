import SwiftUI

private let ratio = Double(20)

extension Navigate {
    struct Draw: View {
        let session: Session
        let annotations: [(title: String, coordinate: CLLocationCoordinate2D)]
        
        var body: some View {
            TimelineView(.periodic(from: .now, by: 0.05)) { timeline in
                Canvas { context, size in
                    session.tick(date: timeline.date, size: size)
                    
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    
                    if let location = session.location {
                        for (title, coordinate) in annotations {
                            let x = location.longitude >= 0
                                ? location.longitude - coordinate.longitude
                                : coordinate.longitude - location.longitude
                            let y = location.latitude >= 0
                                ? location.latitude - coordinate.latitude
                                : coordinate.latitude - location.latitude
                            let delta = ratio * session.zoom * session.zoom
                            let point = CGPoint(x: center.x + (x * delta), y: center.y + (y * delta))
                            
                            context
                                .fill(.init {
                                    $0.addArc(center: point,
                                              radius: 6,
                                              startAngle: .degrees(0),
                                              endAngle: .degrees(360),
                                              clockwise: false)
                                }, with: .color(white: 0.9))
                            
                            if session.visuals {
                                context.draw(Text(title.capped)
                                    .font(.caption2)
                                    .foregroundColor(.secondary),
                                             at: .init(x: point.x, y: point.y + 6),
                                             anchor: .top)
                            }
                        }
                    }
                    
                    context.compass(session: session, center: center)
                }
            }
        }
    }
}

private extension String {
    var capped: Self {
        count > 18 ? prefix(16).trimmingCharacters(in: .whitespacesAndNewlines) + "..." : self
    }
}
