import SwiftUI

extension Create {
    struct Action: View {
        let symbol: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .light))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.primary)
                    .frame(width: 60, height: 45)
                    .contentShape(Rectangle())
            }
        }
    }
}
