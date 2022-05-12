import SwiftUI

extension Loading {
    struct Item: View {
        let title: String
        let content: Text
        
        var body: some View {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
            content
                .font(.callout)
                .lineLimit(1)
        }
    }
}
