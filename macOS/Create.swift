import AppKit
import Coffee
import Combine

final class Create: NSView, NSTextFieldDelegate {
    private weak var name: Field!
    private var subs = Set<AnyCancellable>()
    private let title = CurrentValueSubject<_, Never>("")
    
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        let name = Field()
        self.name = name
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let firstDivider = Separator()
        addSubview(firstDivider)
        
        name.delegate = self
        addSubview(name)
        
        let rename = Control.Button(symbol: "character.cursor.ibeam")
        rename.toolTip = "Change name"
        rename
            .click
            .sink { [weak self] in
                guard case .create = session.flow.value else { return }
                self?.window?.makeFirstResponder(name)
            }
            .store(in: &subs)
        addSubview(rename)
        
        let info = Text(vibrancy: true)
        info.maximumNumberOfLines = 1
        info.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(info)
        
        let secondDivider = Separator()
        addSubview(secondDivider)
        
        let builder = Builder(session: session)
        addSubview(builder)
        
        firstDivider.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        firstDivider.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        firstDivider.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        firstDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        rename.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        
        name.leftAnchor.constraint(equalTo: rename.rightAnchor, constant: 8).isActive = true
        name.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        info.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 20).isActive = true
        info.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -10).isActive = true
        
        secondDivider.topAnchor.constraint(equalTo: firstDivider.bottomAnchor, constant: 50).isActive = true
        secondDivider.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        secondDivider.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        secondDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        builder.topAnchor.constraint(equalTo: secondDivider.bottomAnchor).isActive = true
        builder.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        builder.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        builder.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        [rename, name, info]
            .forEach {
                $0.centerYAnchor.constraint(equalTo: firstDivider.bottomAnchor, constant: 25).isActive = true
            }
        
        builder
            .points
            .map {
                $0.count > 1
            }
            .removeDuplicates()
            .combineLatest(builder.overflow.removeDuplicates()) {
                $0 && !$1
            }
            .sink {
                session.ready.value = $0
            }
            .store(in: &subs)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byTruncatingTail
        
        let caption = [NSAttributedString.Key.font :
                        NSFont.systemFont(ofSize: NSFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular),
                       .foregroundColor: NSColor.tertiaryLabelColor,
                       .paragraphStyle: paragraph]
        
        let values = [NSAttributedString.Key.font :
                        NSFont.monospacedDigitSystemFont(ofSize: NSFont.preferredFont(forTextStyle: .title3).pointSize, weight: .regular),
                      .foregroundColor: NSColor.secondaryLabelColor,
                      .paragraphStyle: paragraph]
        
        builder
            .points
            .map {
                $0.count
            }
            .removeDuplicates()
            .combineLatest(builder.route)
            .sink { points, route in
                let string = NSMutableAttributedString()
                string.append(.init(string: points.formatted(),
                                    attributes: values))
                string.append(.init(string: points == 1 ? " Marker" : " Markers",
                                    attributes: caption))
                
                if !route.isEmpty {
                    string.append(.init(string: " — Distance ",
                                        attributes: caption))
                    
                    string.append(.init(string: Measurement(value: route.distance,
                                                            unit: UnitLength.meters)
                        .formatted(.measurement(width: .abbreviated)),
                                        attributes: values))
                    
                    string.append(.init(string: " — Duration ",
                                        attributes: caption))
                    
                    string.append(.init(string: (Date(timeIntervalSinceNow: -route.duration) ..< Date.now)
                        .formatted(.timeDuration),
                                        attributes: values))
                }
                
                info.attributedStringValue = string
            }
            .store(in: &subs)
        
        session
            .settings
            .sink { origin in
                NSPopover()
                    .show(content: Settings(type: builder.type,
                                            directions: builder.directions,
                                            interest: builder.interest),
                          on: origin,
                          edge: .minY)
            }
            .store(in: &subs)
        
        session
            .options
            .sink { origin in
                NSPopover()
                    .show(content: Options(session: session,
                                           scheme: builder.scheme,
                                           rotate: builder.rotate),
                          on: origin,
                          edge: .minY)
            }
            .store(in: &subs)
        
        session
            .find
            .sink {
                Panel(content: Find(select: builder.select), texted: true)
                    .makeKeyAndOrderFront(nil)
            }
            .store(in: &subs)
    }
    
    func controlTextDidChange(_ notification: Notification) {
        guard let name = notification.object as? Field else { return }
        title.value = name.stringValue
    }
    
    func control(_: NSControl, textView: NSTextView, doCommandBy: Selector) -> Bool {
        switch doCommandBy {
        case #selector(complete),
            #selector(NSSavePanel.cancel),
            #selector(insertNewline),
            #selector(cancelOperation):
            window!.makeFirstResponder(window!.contentView)
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
                name.layer!.backgroundColor = NSColor.quaternaryLabelColor.cgColor
            }
    }
}
