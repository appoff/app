import SwiftUI
import Offline

struct Shared: View {
    let session: Session
    let header: Header
    let image: UIImage
    @State private var url: URL?
    
    var body: some View {
        VStack {
            Text(header.title)
                .font(.title3.weight(.medium))
                .lineLimit(1)
                .frame(maxWidth: 280)
                .padding(.top)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 400)
                .padding(.horizontal)
            
            Spacer()
            
            Button {                
                guard
                    let url = url,
                    let data = image.pngData()
                else { return }
                
                try? data.write(to: url)
                UIApplication.shared.share(url)
            } label: {
                Image(systemName: "square.and.arrow.up.circle")
                    .font(.system(size: 45, weight: .thin))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.primary)
                    .padding()
                    .contentShape(Rectangle())
            }
            
            Spacer()
            
            Button {
                if let url = url {
                    try? FileManager.default.removeItem(at: url)
                }
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    session.flow = .main
                }
            } label: {
                Text("Continue")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)
                    .padding()
                    .contentShape(Rectangle())
            }
            
            Spacer()
        }
        .task {
            url = .init(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(header.title + ".png")
        }
    }
}
