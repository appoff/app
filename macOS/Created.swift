import AppKit
import Combine
import Coffee
import Offline

final class Created: Notify {
    private var subs = Set<AnyCancellable>()

    init(session: Session, header: Header) {
        super.init(size: .init(width: 460, height: 600))
        
        let move = PassthroughSubject<Void, Never>()
        
        let base = Vibrant(layer: false)
        contentView!.addSubview(base)
        
        let image = NSImageView(image: .init(named: "Created") ?? .init())
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentTintColor = .labelColor
        base.addSubview(image)
        
        let title = Text(vibrancy: false)
        title.stringValue = "Ready"
        title.font = .preferredFont(forTextStyle: .title1)
        title.textColor = .labelColor
        base.addSubview(title)
        
        let subtitle = Text(vibrancy: false)
        subtitle.stringValue = header.title
        subtitle.font = .preferredFont(forTextStyle: .title3)
        subtitle.textColor = .secondaryLabelColor
        subtitle.maximumNumberOfLines = 1
        subtitle.lineBreakMode = .byTruncatingTail
        base.addSubview(subtitle)
        
        let upgrade = Upgrade()
        upgrade.isHidden = true
        contentView!.addSubview(upgrade)
        
        let premium = Premium(session: session, header: header, move: move)
        premium.isHidden = true
        contentView!.addSubview(premium)
        
        let accept = Control.Prominent(title: "OK")
        accept.toolTip = "Accept"
        accept
            .click
            .sink { [weak self] in
                self?.close()
            }
            .store(in: &subs)
        contentView!.addSubview(accept)
        
        [image, title, subtitle, upgrade, premium, accept]
            .forEach {
                $0.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            }
        
        base.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        
        image.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 30).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        subtitle.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        upgrade.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 30).isActive = true
        premium.topAnchor.constraint(equalTo: upgrade.topAnchor).isActive = true
        
        accept.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -50).isActive = true
        accept.widthAnchor.constraint(equalToConstant: 120).isActive = true
        accept.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        session
            .premium
            .sink { purchased in
                upgrade.isHidden = purchased
                premium.isHidden = !purchased
            }
            .store(in: &subs)
        
        move
            .sink { [weak self] in
                NSApp
                    .windows
                    .first { $0 is Window }?
                    .orderFrontRegardless()
                self?.close()
            }
            .store(in: &subs)
    }
}
