import AppKit
import StoreKit
import Combine
import Coffee

final class Upgrade: NSView {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = NSImageView(image: .init(systemSymbolName: "clock", accessibilityDescription: nil) ?? .init())
        image.translatesAutoresizingMaskIntoConstraints = false
        image.symbolConfiguration = .init(pointSize: 30, weight: .light)
            .applying(.init(hierarchicalColor: .secondaryLabelColor))
        image.isHidden = true
        addSubview(image)
        
        let text = Text(vibrancy: false)
        text.stringValue = "You are 1 step\nfrom Offline Cloud."
        text.alignment = .center
        text.font = .preferredFont(forTextStyle: .title3)
        text.isHidden = true
        text.textColor = .labelColor
        addSubview(text)
        
        let button = Control.Prominent(title: "Get Offline Cloud")
        button.toolTip = "Purchase Offline Cloud"
        button.color = .windowBackgroundColor
        button.text.textColor = .labelColor
        button.state = .hidden
        button
            .click
            .sink {
                Task {
                    if let product = await store.load(item: .cloud) {
                        await store.purchase(product)
                    } else {
                        store.status.value = .error("Unable to connect to the App Store, try again later.")
                    }
                }
            }
            .store(in: &subs)
        addSubview(button)
        
        let price = Text(vibrancy: false)
        price.isHidden = true
        price.font = .preferredFont(forTextStyle: .callout)
        price.textColor = .secondaryLabelColor
        addSubview(price)
        
        widthAnchor.constraint(equalToConstant: 300).isActive = true
        bottomAnchor.constraint(equalTo: price.topAnchor, constant: 40).isActive = true
        
        image.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        text.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        button.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 10).isActive = true
        button.widthAnchor.constraint(equalToConstant: 180).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        price.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10).isActive = true
        
        [image, text, button, price]
            .forEach {
                $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            }
        
        store
            .status
            .receive(on: DispatchQueue.main)
            .sink {
                switch $0 {
                case .loading:
                    image.isHidden = false
                    text.isHidden = true
                    button.state = .hidden
                    price.isHidden = true
                case .ready:
                    image.isHidden = true
                    text.isHidden = false
                    button.state = .on
                    price.isHidden = false
                case let .error(fail):
                    image.isHidden = true
                    text.isHidden = false
                    button.state = .on
                    price.isHidden = false
                    
                    let alert = NSAlert()
                    alert.alertStyle = .warning
                    alert.icon = .init(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: nil)
                    alert.messageText = fail
                    
                    let accept = alert.addButton(withTitle: "Accept")
                    accept.keyEquivalent = "\r"
                    
                    alert.runModal()
                }
            }
            .store(in: &subs)
        
        Task {
            if let product = await store.load(item: .cloud) {
                await MainActor
                    .run {
                        price.stringValue = "1 time purchase of " + product.displayPrice
                    }
            }
        }
    }
    
    override var allowsVibrancy: Bool {
        true
    }
}
