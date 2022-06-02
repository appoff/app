import SwiftUI

struct Helper: View {
    let symbol: String
    let size: CGFloat
    let title: String
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: symbol)
                .font(.system(size: size, weight: .thin))
                .symbolRenderingMode(.hierarchical)
                .frame(width: 64)
            Text(.init(title)).font(.callout)
            Spacer()
        }
    }
}
