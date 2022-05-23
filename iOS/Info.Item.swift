import SwiftUI

extension Info {
    struct Item: View {
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
        }
    }
}
