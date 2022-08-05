import AppKit
import Coffee
import Combine

final class Sidebar: NSVisualEffectView, NSTextFieldDelegate {
    private weak var field: Field!
    private weak var cancel: Control.Plain!
    private var subs = Set<AnyCancellable>()
    private let session: Session
    
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        self.session = session
        let field = Field(session: session)
        self.field = field
        
        let cancel = Control.Plain(title: "Cancel")
        self.cancel = cancel
        
        super.init(frame: .zero)
        state = .active
        material = .hudWindow
        translatesAutoresizingMaskIntoConstraints = false
        
        field.delegate = self
        field.isHidden = true
        addSubview(field)
        
        cancel.toolTip = "Cancel search"
        cancel.state = .hidden
        cancel
            .click
            .sink { [weak self] in
                field.stringValue = ""
//                session.search.send("")
                self?.update()
            }
            .store(in: &subs)
        addSubview(cancel)
        
        let count = Text(vibrancy: true)
        count.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        count.maximumNumberOfLines = 1
        count.isHidden = true
        addSubview(count)
        
        let divider = Separator()
        divider.isHidden = true
        addSubview(divider)
        
        let separator = Separator()
        addSubview(separator)
        
        widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        field.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        field.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        field.widthAnchor.constraint(equalToConstant: 160).isActive = true
        
        cancel.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        cancel.leftAnchor.constraint(equalTo: field.rightAnchor, constant: 3).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        count.centerYAnchor.constraint(equalTo: topAnchor, constant: 26).isActive = true
        let trailing = count.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20)
        let leading = count.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor)
        trailing.priority = .defaultLow
        trailing.isActive = true
        leading.isActive = true

        divider.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        divider.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        separator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byTruncatingTail
        
        let countAttributes = AttributeContainer([.font: NSFont
            .monospacedDigitSystemFont(
                ofSize: NSFont.preferredFont(forTextStyle: .body).pointSize,
                weight: .regular),
                                                  .foregroundColor: NSColor.secondaryLabelColor,
                                                  .paragraphStyle: paragraph])
        let titleAttributes = AttributeContainer([.font: NSFont.preferredFont(forTextStyle: .body),
                                                  .foregroundColor: NSColor.tertiaryLabelColor,
                                                  .paragraphStyle: paragraph])
        
//        session
//            .items
//            .combineLatest(session
//                .showing
//                .removeDuplicates())
//            .sink { items, showing in
//                var string = AttributedString(items.count.formatted(),
//                                              attributes: countAttributes)
//                string.append(AttributedString(" ", attributes: titleAttributes))
//
//                let title: String
//
//                switch showing {
//                case 0:
//                    title = items.count == 1 ? "article" : "articles"
//                    filter.image.image = .init(systemSymbolName: "line.3.horizontal.decrease.circle", accessibilityDescription: nil)
//                case 1:
//                    title = "not read"
//                    filter.image.image = .init(systemSymbolName: "line.3.horizontal.decrease.circle.fill", accessibilityDescription: nil)
//                default:
//                    title = items.count == 1 ? "bookmark" : "bookmarks"
//                    filter.image.image = .init(systemSymbolName: "line.3.horizontal.decrease.circle.fill", accessibilityDescription: nil)
//                }
//
//                string.append(AttributedString(title, attributes: titleAttributes))
//                count.attributedStringValue = .init(string)
//            }
//            .store(in: &subs)
        
//        session
//            .find
//            .sink { [weak self] in
//                self?.window?.makeFirstResponder(field)
//            }
//            .store(in: &subs)
        
//        NotificationCenter
//            .default
//            .publisher(for: NSView.boundsDidChangeNotification)
//            .compactMap {
//                $0.object as? NSClipView
//            }
//            .filter {
//                $0 == list.contentView
//            }
//            .map {
//                $0.bounds.minY < 10
//            }
//            .removeDuplicates()
//            .sink {
//                divider.isHidden = $0
//            }
//            .store(in: &subs)
    }
    
    func controlTextDidChange(_ notification: Notification) {
        guard let search = notification.object as? Field else { return }
//        session.search.send(search.stringValue)
        update()
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy: Selector) -> Bool {
        switch doCommandBy {
        case #selector(cancelOperation):
            field.cancelOperation(nil)
            update()
            return true
        case #selector(complete),
            #selector(NSSavePanel.cancel),
            #selector(insertNewline):
            window!.makeFirstResponder(window!.contentView)
            update()
            return true
        default:
            return false
        }
    }
    
    override func updateLayer() {
        super.updateLayer()
        
        NSApp
            .effectiveAppearance
            .performAsCurrentDrawingAppearance {
                field.layer!.backgroundColor = NSColor.quaternaryLabelColor.cgColor
            }
    }
    
    private func update() {
        cancel.state = field.stringValue.isEmpty ? .off : .on
    }
}
