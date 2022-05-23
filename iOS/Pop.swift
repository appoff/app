import SwiftUI

struct Pop<Content>: View where Content : View {
    let title: String
    private let content: Content
    @Environment(\.dismiss) private var dismiss
    
    @inlinable public init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text(title)
                    .font(.body.weight(.medium))
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28, weight: .light))
                        .frame(width: 36, height: 36)
                        .padding(.trailing, 12)
                        .contentShape(Rectangle())
                }
            }
            .padding(.top, 12)
            
            content
            
            Spacer()
        }
    }
}
