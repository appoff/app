import AppKit
import Combine
import Coffee
import Offline

final class Created: NSView {
    private var subs = Set<AnyCancellable>()

    required init?(coder: NSCoder) { nil }
    init(session: Session, header: Header) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = NSImageView(image: .init(named: "Created") ?? .init())
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentTintColor = .labelColor
        addSubview(image)
        
        let title = Text(vibrancy: false)
        title.stringValue = "Ready"
        title.font = .preferredFont(forTextStyle: .title1)
        title.textColor = .labelColor
        addSubview(title)
        
        let subtitle = Text(vibrancy: false)
        subtitle.stringValue = header.title
        subtitle.font = .preferredFont(forTextStyle: .title3)
        subtitle.textColor = .secondaryLabelColor
        subtitle.maximumNumberOfLines = 1
        subtitle.lineBreakMode = .byTruncatingTail
        addSubview(subtitle)
        
        let upgrade = Upgrade()
        upgrade.isHidden = true
        addSubview(upgrade)
        
        let premium = Premium(session: session, header: header)
        premium.isHidden = true
        addSubview(premium)
        
        let accept = Control.Plain(title: "OK")
        accept.toolTip = "Accept"
        accept
            .click
            .sink { [weak self] in
                session.flow.value = .main
            }
            .store(in: &subs)
        addSubview(accept)
        
        [image, title, subtitle, upgrade, premium, accept]
            .forEach {
                $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            }
        
        image.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 45).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        subtitle.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        upgrade.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 30).isActive = true
        premium.topAnchor.constraint(equalTo: upgrade.topAnchor).isActive = true
        
        accept.topAnchor.constraint(equalTo: upgrade.bottomAnchor, constant: 50).isActive = true
        accept.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        session
            .premium
            .sink { purchased in
                upgrade.isHidden = purchased
                premium.isHidden = !purchased
            }
            .store(in: &subs)
    }
    
    override var allowsVibrancy: Bool {
        true
    }
}
