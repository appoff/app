import SwiftUI
import Offline

struct Download: View {
    let session: Session
    let header: Header
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "icloud.and.arrow.down")
                .font(.system(size: 60, weight: .ultraLight))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)
            
            Text("Downloading")
                .font(.title2.weight(.regular))
                .padding(.top)
            
            Text(header.title)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: 280)
            
            Spacer()
        }
    }
}
