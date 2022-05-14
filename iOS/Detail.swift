import SwiftUI
import Offline

struct Detail: View {
    let session: Session
    let map: Offline.Map
    let namespace: Namespace.ID
    let thumbnail: UIImage?
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(.tertiarySystemBackground))
                .matchedGeometryEffect(id: "background", in: namespace)
            VStack {
                ZStack(alignment: .top) {
                    if let thumbnail = thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .matchedGeometryEffect(id: "image", in: namespace)
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        
                    }
                    HStack {
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                session.selected = nil
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
                    .matchedGeometryEffect(id: "info", in: namespace)
                Spacer()
            }
        }
        .matchedGeometryEffect(id: "card", in: namespace)
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                opacity = 1
            }
        }
    }
}
