import SwiftUI

struct Action: View {
    var size = CGFloat(20)
    let symbol: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.primary)
                .frame(width: 64, height: 60)
                .contentShape(Rectangle())
        }
    }
}
