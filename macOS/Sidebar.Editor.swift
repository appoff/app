import AppKit

extension Sidebar {
    final class Editor: NSTextView {
        override init(frame: NSRect, textContainer: NSTextContainer?) {
            super.init(frame: frame, textContainer: textContainer)
        }
        
        required init?(coder: NSCoder) { nil }
        init() {
            super.init(frame: .zero)
            allowsUndo = true
            isFieldEditor = true
            isRichText = false
            isContinuousSpellCheckingEnabled = false
            isAutomaticTextCompletionEnabled = false
            insertionPointColor = .labelColor
        }
        
        override var allowsVibrancy: Bool {
            true
        }
    
        override func paste(_ sender: Any?) {
            let clean = {
                $0
                    .replacingOccurrences(of: "\n", with: " ")
                    .replacingOccurrences(of: "\r", with: " ")
                    .replacingOccurrences(of: "\t", with: " ")
                    .replacingOccurrences(of: "  ", with: " ")
            } ((NSPasteboard.general.string(forType: .string) ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines))
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(clean, forType: .string)
            super.paste(sender)
        }
        
        override func becomeFirstResponder() -> Bool {
            selectedTextAttributes[.backgroundColor] = NSColor.quaternaryLabelColor
            return super.becomeFirstResponder()
        }
    }
}
