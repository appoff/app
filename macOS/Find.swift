import MapKit
import Coffee
import Combine
import Offline

final class Find: NSView, NSTextFieldDelegate {
    private weak var field: Field!
    private weak var xmark: Control.Symbol!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(select: PassthroughSubject<MKLocalSearchCompletion, Never>) {
        super.init(frame: .init(x: 0, y: 0, width: 400, height: 300))
     
        let magnifier = NSImageView(image: .init(systemSymbolName: "magnifyingglass", accessibilityDescription: nil) ?? .init())
        magnifier.translatesAutoresizingMaskIntoConstraints = false
        magnifier.symbolConfiguration = .init(pointSize: 16, weight: .regular)
            .applying(.init(hierarchicalColor: .tertiaryLabelColor))
        addSubview(magnifier)
        
        let field = Field()
        self.field = field
        addSubview(field)
        
        let xmark = Control.Symbol(symbol: "xmark.circle.fill", size: 20)
        xmark.state = .off
        xmark
            .click
            .sink { [weak self] in
                field.stringValue = ""
                self?.update()
            }
            .store(in: &subs)
        addSubview(xmark)
        self.xmark = xmark
        
        let separator = Separator()
        addSubview(separator)
        
        magnifier.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        magnifier.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        
        field.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        field.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        field.rightAnchor.constraint(equalTo: rightAnchor, constant: -45).isActive = true
        
        xmark.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        xmark.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        
        separator.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 10).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
    }
    
    private func update() {
        xmark.state = field.stringValue.isEmpty ? .off : .on
    }
}
