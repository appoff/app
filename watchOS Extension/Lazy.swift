import SwiftUI

struct Lazy<Content>: View where Content : View {
    private let content: () -> Content
    
    init(_ content: @autoclosure @escaping () -> Content) {
        self.content = content
    }
    
    var body: Content {
        content()
    }
}
