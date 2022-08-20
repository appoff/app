import AppKit
import Coffee
import Offline

final class Created: Notify {
    init(header: Header) {
        super.init(size: .init(width: 300, height: 400))
        
        let base = Vibrant(layer: false)
        contentView!.addSubview(base)
        
        let image = NSImageView(image: .init(named: "Created") ?? .init())
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentTintColor = .secondaryLabelColor
        base.addSubview(image)
        
        let title = Text(vibrancy: false)
        title.stringValue = "Ready"
        title.font = .preferredFont(forTextStyle: .title1)
        title.textColor = .secondaryLabelColor
        base.addSubview(title)
        
        let subtitle = Text(vibrancy: false)
        subtitle.stringValue = header.title
        subtitle.font = .preferredFont(forTextStyle: .title3)
        subtitle.textColor = .tertiaryLabelColor
        base.addSubview(subtitle)
        
        if Defaults.cloud {
            
        } else {
            
        }
        
        base.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
    }
}
