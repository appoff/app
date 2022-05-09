import SwiftUI
import Offline

extension Create {
    struct Pop<Content>: View where Content : View {
        @Environment(\.dismiss) private var dismiss
        private let content: Content
        
        @inlinable public init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                            .padding([.trailing, .top], 15)
                            .contentShape(Rectangle())
                    }
                }
                
                content
                
                Spacer()
            }
        }
    }
}
