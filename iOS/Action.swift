import SwiftUI

struct Action: View {
    let symbol: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.primary)
                .frame(width: 64, height: 60)
                .contentShape(Rectangle())
        }
    }
}
