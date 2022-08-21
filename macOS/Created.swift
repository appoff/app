import AppKit
import Combine
import Coffee
import Offline

final class Created: Notify {
    private var subs = Set<AnyCancellable>()
    
    init(session: Session, header: Header) {
        super.init(size: .init(width: 400, height: 540))
        
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
        base.addSubview(subtitle)
        
        let upgrade = Upgrade(session: session)
        upgrade.isHidden = true
        contentView!.addSubview(upgrade)
        
        [image, title, subtitle, upgrade]
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
        subtitle.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        upgrade.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 30).isActive = true
        
        session
            .premium
            .sink { premium in
                upgrade.isHidden = premium
            }
            .store(in: &subs)
    }
}
