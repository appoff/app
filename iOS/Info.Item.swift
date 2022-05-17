import SwiftUI

extension Info {
    struct Item: View {
        let title: String
        let content: Text
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                VStack {
                    Divider()
                }
            }
            content
                .font(.caption)
        }
    }
}
