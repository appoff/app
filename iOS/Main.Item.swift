import SwiftUI
import Offline

extension Main {
    struct Item: View {
        let session: Session
        let map: Offline.Map
        let thumbnail: UIImage?
        @Namespace private var namespace
        
        var body: some View {
            Button {
                withAnimation(.easeInOut(duration: 0.4)) {
                    session.selected = (map: map, namespace: namespace)
                }
            } label: {
                ZStack {
                    Rectangle()
                        .fill(Color(.tertiarySystemBackground))
                        .matchedGeometryEffect(id: "background", in: namespace)
                    VStack(spacing: 0) {
                        if let thumbnail = thumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .matchedGeometryEffect(id: "image", in: namespace)
                                .scaledToFill()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        }
                        Info(map: map, size: 0)
                            .matchedGeometryEffect(id: "info", in: namespace)
                            .lineLimit(1)
                            .padding(.bottom)
                    }
                }
                .matchedGeometryEffect(id: "card", in: namespace)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .init(white: 0, opacity: 0.1), radius: 8, y: 6)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 10)
        }
    }
}
