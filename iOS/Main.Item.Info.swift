import SwiftUI

extension Main.Item {
    struct Info: View {
        let title: String
        let content: Text
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                VStack {
                    Divider()
                }
            }
            content
                .font(.footnote)
                .lineLimit(1)
        }
    }
}
