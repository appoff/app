import SwiftUI
import Offline

extension Main {
    struct Item: View {
        let session: Session
        let map: Offline.Map
        let thumbnail: UIImage?
        let animation: Namespace.ID
        
        var body: some View {
            Button {
                withAnimation(.easeInOut(duration: 5)) {
                    session.flow = .detail(map, thumbnail)
                }
            } label: {
                ZStack {
                    Rectangle()
                        .fill(Color(.tertiarySystemBackground))
                        .matchedGeometryEffect(id: "background.\(map.id.uuidString)", in: animation)
                    VStack(spacing: 0) {
                        if let thumbnail = thumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .matchedGeometryEffect(id: "image.\(map.id.uuidString)", in: animation)
                                .scaledToFill()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        }
                        Info(map: map, constrain: true)
                            .matchedGeometryEffect(id: "info.\(map.id.uuidString)", in: animation)
                    }
                }
                .matchedGeometryEffect(id: "card.\(map.id.uuidString)", in: animation)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .init(white: 0, opacity: 0.1), radius: 8, y: 6)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 10)
        }
    }
}
