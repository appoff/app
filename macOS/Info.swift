import AppKit
import Coffee
import Offline

final class Info: NSView {
    private let oversize: CGFloat
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, header: Header, full: Bool) {
        oversize = full ? 6 : 0
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let title = Text(vibrancy: false)
        title.stringValue = header.title
        title.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .callout).pointSize + oversize, weight: .medium)
        title.textColor = .labelColor
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        title.maximumNumberOfLines = 1
        title.lineBreakMode = .byTruncatingTail
        
        let origin = item(title: "Origin", content: header.origin)
        let destination = item(title: "Destination", content: header.destination)
        
        [title, origin, destination]
            .forEach {
                addSubview($0)
                
                $0.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                $0.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            }
        
        title.topAnchor.constraint(equalTo: topAnchor).isActive = true
        origin.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5 + oversize).isActive = true
        destination.topAnchor.constraint(equalTo: origin.bottomAnchor, constant: 5 + oversize).isActive = true
        
        if full {
            Task {
                let size = await session.local.size(header: header) ?? 0
                
                let distance = item(title: "Distance",
                                    content: Measurement(value: .init(header.distance),
                                                         unit: UnitLength.meters)
                                        .formatted(.measurement(width: .abbreviated)))
                let duration = item(title: "Duration",
                                    content: (Date(timeIntervalSinceNow: -.init(header.duration)) ..< Date.now)
                    .formatted(.timeDuration))
                let weight = item(title: "Size",
                                  content: size.formatted(.byteCount(style: .file)))
                
                [distance, duration, weight]
                    .forEach {
                        addSubview($0)
                        
                        $0.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                        $0.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
                    }
                
                bottomAnchor.constraint(equalTo: weight.bottomAnchor).isActive = true
                
                distance.topAnchor.constraint(equalTo: destination.bottomAnchor, constant: 5 + oversize).isActive = true
                duration.topAnchor.constraint(equalTo: distance.bottomAnchor, constant: 5 + oversize).isActive = true
                weight.topAnchor.constraint(equalTo: duration.bottomAnchor, constant: 5 + oversize).isActive = true
            }
        } else {
            bottomAnchor.constraint(equalTo: destination.bottomAnchor).isActive = true
        }
    }
    
    private func item(title: String, content: String) -> NSView {
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        
        let header = Text(vibrancy: false)
        header.stringValue = title
        header.textColor = .tertiaryLabelColor
        header.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .caption2).pointSize + oversize, weight: .regular)
        header.maximumNumberOfLines = 1
        header.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        base.addSubview(header)
        
        let divider = Separator()
        base.addSubview(divider)
        
        let text = Text(vibrancy: false)
        text.stringValue = content
        text.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .caption1).pointSize + oversize, weight: .regular)
        text.textColor = .secondaryLabelColor
        text.maximumNumberOfLines = 1
        text.lineBreakMode = .byTruncatingTail
        text.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        base.addSubview(text)
        
        base.bottomAnchor.constraint(equalTo: text.bottomAnchor).isActive = true
        
        header.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        header.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        header.widthAnchor.constraint(lessThanOrEqualToConstant: 140).isActive = true
        
        divider.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.leftAnchor.constraint(equalTo: header.rightAnchor, constant: 5).isActive = true
        divider.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        text.topAnchor.constraint(equalTo: header.bottomAnchor, constant: oversize).isActive = true
        text.leftAnchor.constraint(equalTo: header.leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: divider.rightAnchor).isActive = true
        
        return base
    }
}
