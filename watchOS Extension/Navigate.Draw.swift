import SwiftUI

private let ratio = Double(20)

extension Navigate {
    struct Draw: View {
        let session: Session
        let points: [(title: String, coordinate: CLLocationCoordinate2D)]
        let route: [CLLocationCoordinate2D]
        @Environment(\.scenePhase) private var phase
        
        var body: some View {
            TimelineView(.periodic(from: .now, by: phase == .active ? 0.05 : 5)) { timeline in
                Canvas { context, size in
                    if phase == .active {
                        session.tick(date: timeline.date, size: size)
                    }
                    
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let value = abs(session.zoom - 20)
                    let zoom = ratio * value * value * 25
                    
                    if let location = session.location {
                        if session.visuals {
                            context
                                .stroke(.init { path in
                                    path.addLines(route
                                        .map {
                                            point(location: location, coordinate: $0, center: center, zoom: zoom)
                                        })
                                }, with: .color(white: 1, opacity: 0.35),
                                        style: .init(lineWidth: 6, lineCap: .round, lineJoin: .round))
                        }
                        
                        for (title, coordinate) in points {
                            let point = point(location: location, coordinate: coordinate, center: center, zoom: zoom)
                            
                            context
                                .fill(.init {
                                    $0.addArc(center: point,
                                              radius: 7,
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
        
        private func point(location: CLLocationCoordinate2D, coordinate: CLLocationCoordinate2D, center: CGPoint, zoom: Double) -> CGPoint {
            let x = location.longitude >= 0
                ? location.longitude - coordinate.longitude
                : coordinate.longitude - location.longitude
            let y = location.latitude >= 0
                ? location.latitude - coordinate.latitude
                : coordinate.latitude - location.latitude

            return .init(x: center.x + (x * zoom), y: center.y + (y * zoom))
        }
    }
}

private extension String {
    var capped: Self {
        count > 16 ? prefix(14).trimmingCharacters(in: .whitespacesAndNewlines) + "..." : self
    }
}
