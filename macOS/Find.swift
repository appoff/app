import MapKit
import Coffee
import Combine
import Offline

final class Find: NSView, NSTextFieldDelegate, MKLocalSearchCompleterDelegate {
    private weak var field: Field!
    private weak var xmark: Control.Symbol!
    private var subs = Set<AnyCancellable>()
    private let completer = MKLocalSearchCompleter()
    private let results = PassthroughSubject<[MKLocalSearchCompletion], Never>()
    
    required init?(coder: NSCoder) { nil }
    init(select: PassthroughSubject<MKLocalSearchCompletion, Never>) {
        super.init(frame: .init(x: 0, y: 0, width: 400, height: 300))
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest, .query]
        completer.pointOfInterestFilter = .includingAll
     
        let magnifier = NSImageView(image: .init(systemSymbolName: "magnifyingglass", accessibilityDescription: nil) ?? .init())
        magnifier.translatesAutoresizingMaskIntoConstraints = false
        magnifier.symbolConfiguration = .init(pointSize: 16, weight: .regular)
            .applying(.init(hierarchicalColor: .tertiaryLabelColor))
        addSubview(magnifier)
        
        let field = Field()
        field.delegate = self
        self.field = field
        addSubview(field)
        
        let xmark = Control.Symbol(symbol: "xmark.circle.fill", size: 20, background: false)
        xmark.state = .off
        xmark
            .click
            .sink { [weak self] in
                self?.completer.cancel()
                field.stringValue = ""
                self?.update()
            }
            .store(in: &subs)
        addSubview(xmark)
        self.xmark = xmark
        
        let separator = Separator()
        addSubview(separator)
        
        let flip = Flip()
        flip.translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.documentView = flip
        scroll.hasVerticalScroller = true
        scroll.verticalScroller!.controlSize = .mini
        scroll.drawsBackground = false
        scroll.scrollerInsets.top = 5
        scroll.scrollerInsets.bottom = 5
        scroll.automaticallyAdjustsContentInsets = false
        scroll.contentView.postsBoundsChangedNotifications = false
        scroll.contentView.postsFrameChangedNotifications = false
        addSubview(scroll)
        
        let stack = Stack()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.orientation = .vertical
        stack.spacing = 0
        flip.addSubview(stack)
        
        magnifier.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        magnifier.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        
        field.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        field.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        field.rightAnchor.constraint(equalTo: rightAnchor, constant: -45).isActive = true
        
        xmark.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        xmark.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        
        separator.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 5).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        
        scroll.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        flip.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        flip.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        flip.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
        flip.bottomAnchor.constraint(equalTo: stack.bottomAnchor).isActive = true
        
        stack.topAnchor.constraint(equalTo: flip.topAnchor, constant: 1).isActive = true
        stack.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        stack.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        
        let complete = PassthroughSubject<String, Never>()
        complete
            .sink {
                field.stringValue = $0
            }
            .store(in: &subs)
        
        results
            .removeDuplicates()
            .sink { results in
                scroll.contentView.bounds.origin.y = 0
                stack.setViews(results
                    .map {
                        Item(item: $0, select: select, complete: complete)
                    }, in: .center)
            }
            .store(in: &subs)
    }
    
    override var allowsVibrancy: Bool {
        true
    }
    
    func completerDidUpdateResults(_: MKLocalSearchCompleter) {
        results.send(completer.results)
    }
    
    func controlTextDidChange(_ notification: Notification) {
        guard let field = notification.object as? Field else { return }
        completer.cancel()
        completer.queryFragment = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        update()
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy: Selector) -> Bool {
        switch doCommandBy {
        case #selector(cancelOperation):
            completer.cancel()
            window?.close()
            return true
        case #selector(complete),
            #selector(NSSavePanel.cancel),
            #selector(insertNewline):
            return true
        default:
            return false
        }
    }
    
    private func update() {
        xmark.state = field.stringValue.isEmpty ? .off : .on
    }
}
