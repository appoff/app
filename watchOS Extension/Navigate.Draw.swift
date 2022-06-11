import SwiftUI

private let ratio = Double(20)

extension Navigate {
    struct Draw: View {
        let session: Session
        let points: [(title: String, coordinate: CLLocationCoordinate2D)]
        let route: [CLLocationCoordinate2D]
        @Environment(\.scenePhase) private var phase
        
        var body: some View {
            TimelineView(.periodic(from: .now, by: phase == .active ? 0.025 : 5)) { timeline in
                Canvas { context, size in
                    if phase == .active {
                        session.tick(date: timeline.date, size: size)
                    }
                    
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let zoom = ratio * session.zoom * session.zoom * 25
                    
                    if let location = session.location {
                        if session.visuals {
                            context
                                .stroke(.init { path in
                                    path.addLines(route
                                        .map {
                                            point(location: location, coordinate: $0, center: center, zoom: zoom)
                                        })
                                }, with: .color(white: 1, opacity: 0.3),
                                        style: .init(lineWidth: 7, lineCap: .round, lineJoin: .round))
                        }
                        
                        for (title, coordinate) in points {
                            let point = point(location: location, coordinate: coordinate, center: center, zoom: zoom)
                            
                            context
                                .stroke(.init {
                                    $0.addArc(center: point,
                                              radius: 11,
                                              startAngle: .degrees(0),
                                              endAngle: .degrees(360),
                                              clockwise: false)
                                }, with: .color(white: 1), lineWidth: 2)
                            
                            context
                                .fill(.init {
                                    $0.addArc(center: point,
                                              radius: 9,
                                              startAngle: .degrees(0),
                                              endAngle: .degrees(360),
                                              clockwise: false)
                                }, with: .color(white: 1, opacity: 0.5))
                            
                            if session.visuals {
                                context.draw(Text(title.capped)
                                    .font(.caption2.weight(.light))
                                    .foregroundColor(.primary.opacity(0.5)),
                                             at: .init(x: point.x, y: point.y + 11),
                                             anchor: .top)
                            }
                        }
                    } else {
                        context
                            .draw(Text(Image(systemName: "location.slash.fill"))
                                .font(.system(size: 30, weight: .regular))
                                .foregroundColor(.primary.opacity(0.35)),
                                  at: .init(x: 10, y: 10),
                                  anchor: .topLeading)
                    }
                    
                    context.compass(session: session, size: size, center: center, active: phase == .active)
                }
            }
        }
        
        private func point(location: CLLocationCoordinate2D, coordinate: CLLocationCoordinate2D, center: CGPoint, zoom: Double) -> CGPoint {
            let x = coordinate.longitude - location.longitude
            let y = location.latitude - coordinate.latitude

            return .init(x: center.x + (x * zoom), y: center.y + (y * zoom))
        }
    }
}

private extension String {
    var capped: Self {
        count > 20 ? prefix(18).trimmingCharacters(in: .whitespacesAndNewlines) + "..." : self
    }
}
