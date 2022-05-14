import SwiftUI
import Offline

struct Detail: View {
    let session: Session
    let map: Offline.Map
    let thumbnail: UIImage?
    let animation: Namespace.ID
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(.tertiarySystemBackground))
                .matchedGeometryEffect(id: "background.\(map.id.uuidString)", in: animation)
            VStack {
                ZStack(alignment: .top) {
                    if let thumbnail = thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .matchedGeometryEffect(id: "image.\(map.id.uuidString)", in: animation)
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        
                    }
                    HStack {
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                session.flow = .main
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28, weight: .light))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.primary, Color(.systemBackground).opacity(0.5))
                                .frame(width: 80, height: 80)
                        }
                        .opacity(opacity)
                    }
                }
                Info(map: map, constrain: false)
                    .matchedGeometryEffect(id: "info.\(map.id.uuidString)", in: animation)
                Spacer()
            }
        }
        .matchedGeometryEffect(id: "card.\(map.id.uuidString)", in: animation)
        .edgesIgnoringSafeArea([.top, .leading, .trailing])
        .statusBar(hidden: true)
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                opacity = 1
            }
        }
    }
}
