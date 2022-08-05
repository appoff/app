import AppKit

extension Sidebar {
    final class Field: NSTextField {
        private let session: Session
        
        override var canBecomeKeyView: Bool {
            false
        }
        
        required init?(coder: NSCoder) { nil }
        init(session: Session) {
            Self.cellClass = Cell.self
            self.session = session
            
            super.init(frame: .zero)
            bezelStyle = .roundedBezel
            translatesAutoresizingMaskIntoConstraints = false
            font = .preferredFont(forTextStyle: .body)
            controlSize = .large
            lineBreakMode = .byTruncatingTail
            textColor = .labelColor
            isAutomaticTextCompletionEnabled = false
            placeholderString = "Search"
            wantsLayer = true
            layer!.cornerRadius = 8
            layer!.cornerCurve = .continuous
        }
        
        deinit {
            NSApp
                .windows
                .forEach {
                    $0.undoManager?.removeAllActions()
                }
        }
        
        override func cancelOperation(_: Any?) {
            stringValue = ""
            undoManager?.removeAllActions()
//            session.search.send("")
            window?.makeFirstResponder(nil)
        }
        
        override func becomeFirstResponder() -> Bool {
            undoManager?.removeAllActions()
            return super.becomeFirstResponder()
        }
    }
}
