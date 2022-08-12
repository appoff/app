import AppKit

extension Find {
    final class Field: NSTextField {
        required init?(coder: NSCoder) { nil }
        init() {
            Self.cellClass = Cell.self
            
            super.init(frame: .zero)
            bezelStyle = .roundedBezel
            translatesAutoresizingMaskIntoConstraints = false
            font = .systemFont(ofSize: 16, weight: .regular)
            controlSize = .large
            lineBreakMode = .byTruncatingTail
            textColor = .labelColor
            isAutomaticTextCompletionEnabled = false
            placeholderString = "New map"
            maximumNumberOfLines = 1
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
            undoManager?.removeAllActions()
            window?.close()
        }
        
        override func becomeFirstResponder() -> Bool {
            undoManager?.removeAllActions()
            return super.becomeFirstResponder()
        }
    }
}
