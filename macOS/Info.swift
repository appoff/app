import AppKit
import Coffee
import Offline

final class Info: NSView {
    required init?(coder: NSCoder) { nil }
    init(header: Header, size: Int, oversize: CGFloat) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let title = Text(vibrancy: false)
        title.stringValue = header.title
        title.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .callout).pointSize + oversize, weight: .medium)
        title.textColor = .labelColor
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        title.maximumNumberOfLines = 1
        title.lineBreakMode = .byTruncatingTail
        
        let origin = item(title: "Origin", content: header.origin, oversize: oversize)
        let destination = item(title: "Destination", content: header.destination, oversize: oversize)
        
        [title, origin, destination]
            .forEach {
                addSubview($0)
                
                $0.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                $0.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            }
        
        title.topAnchor.constraint(equalTo: topAnchor).isActive = true
        origin.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5 + oversize).isActive = true
        destination.topAnchor.constraint(equalTo: origin.bottomAnchor, constant: 5 + oversize).isActive = true
        
        if size > 0 {
            
        } else {
            bottomAnchor.constraint(equalTo: destination.bottomAnchor).isActive = true
        }
    }
    
    private func item(title: String, content: String, oversize: CGFloat) -> NSView {
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
        
        text.topAnchor.constraint(equalTo: header.bottomAnchor, constant: oversize == 0 ? 0 : oversize).isActive = true
        text.leftAnchor.constraint(equalTo: header.leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: divider.rightAnchor).isActive = true
        
        return base
    }
}
