import AppKit

final class Create: NSView {
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
}
