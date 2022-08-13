import AppKit
import Coffee

extension Create {
    final class Help: NSView {
        required init?(coder: NSCoder) { nil }
        init() {
            super.init(frame: .init(x: 0, y: 0, width: 520, height: 440))
            
            let scroll = Scroll()
            scroll.contentView.postsBoundsChangedNotifications = false
            scroll.contentView.postsFrameChangedNotifications = false
            addSubview(scroll)
            
            let stack = Stack()
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.orientation = .vertical
            stack.spacing = 0
            scroll.documentView!.addSubview(stack)
            
            scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
            scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
}
