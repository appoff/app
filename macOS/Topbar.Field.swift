import AppKit

extension Topbar {
    final class Field: NSTextField {
        private let session: Session
        
        required init?(coder: NSCoder) { nil }
        init(session: Session) {
            self.session = session
            Self.cellClass = Cell.self
            
            super.init(frame: .zero)
            bezelStyle = .roundedBezel
            translatesAutoresizingMaskIntoConstraints = false
            font = .systemFont(ofSize: 14, weight: .regular)
            controlSize = .large
            lineBreakMode = .byTruncatingTail
            textColor = .labelColor
            isAutomaticTextCompletionEnabled = false
            placeholderString = "New map"
            maximumNumberOfLines = 1
        }
        
        deinit {
            NSApp
                .windows
                .forEach {
                    $0.undoManager?.removeAllActions()
                }
        }
        
        override var canBecomeKeyView: Bool {
            false
        }
        
        override func cancelOperation(_: Any?) {
            stringValue = ""
            undoManager?.removeAllActions()
            window?.makeFirstResponder(nil)
        }
        
        override func becomeFirstResponder() -> Bool {
            undoManager?.removeAllActions()
            return super.becomeFirstResponder()
        }
    }
}
