import SwiftUI
import Offline

extension Main {
    struct Item: View {
        let session: Session
        let project: Project
        @Namespace private var namespace
        
        var body: some View {
            Button {
                withAnimation(.easeInOut(duration: 0.4)) {
                    session.selected = (project: project, namespace: namespace)
                }
            } label: {
                ZStack {
                    Rectangle()
                        .fill(Color(.tertiarySystemBackground))
                        .matchedGeometryEffect(id: "background", in: namespace)
                    VStack(spacing: 0) {
                        if let thumbnail = project.schema.flatMap { UIImage(data: $0.thumbnail) } {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .matchedGeometryEffect(id: "image", in: namespace)
                                .scaledToFill()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        } else {
                            Image(systemName: "cloud")
                                .font(.system(size: 60, weight: .ultraLight))
                                .matchedGeometryEffect(id: "image", in: namespace)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.secondary)
                                .padding(.top, 30)
                                .padding(.bottom)
                        }
                        Info(header: project.header, size: 0)
                            .matchedGeometryEffect(id: "info", in: namespace)
                            .lineLimit(1)
                            .padding(.bottom, 20)
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
