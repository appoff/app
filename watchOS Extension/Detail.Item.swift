import SwiftUI

extension Detail {
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
            .padding(.top, 10)
            content
                .font(.footnote)
                .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
        }
    }
}
