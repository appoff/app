import AppKit
import Coffee

extension Create {
    final class Overflow: NSView {
        private(set) weak var height: NSLayoutConstraint!
        
        required init?(coder: NSCoder) { nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let image = NSImageView(image: .init(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil) ?? .init())
            image.translatesAutoresizingMaskIntoConstraints = false
            image.symbolConfiguration = .init(pointSize: 40, weight: .thin)
                .applying(.init(hierarchicalColor: .secondaryLabelColor))
            addSubview(image)
            
            let string = NSMutableAttributedString()
            string.append(.init(string: "Map too big",
                                attributes: [
                                    .font: NSFont.systemFont(ofSize: NSFont.preferredFont(forTextStyle: .title3).pointSize, weight: .regular),
                                    .foregroundColor: NSColor.labelColor]))
            string.append(.init(string: "\nTry a smaller map with points closer to each other.",
                                attributes: [
                                    .font: NSFont.systemFont(ofSize: NSFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular),
                                    .foregroundColor: NSColor.secondaryLabelColor]))
            
            let text = Text(vibrancy: false)
            text.attributedStringValue = string
            addSubview(text)
            
            let divider = Separator()
            addSubview(divider)
            
            height = heightAnchor.constraint(equalToConstant: 0)
            height.isActive = true
            
            image.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            image.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            
            text.centerYAnchor.constraint(equalTo: image.centerYAnchor).isActive = true
            text.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 20).isActive = true
            
            divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
            divider.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            divider.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            divider.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
        
        override var allowsVibrancy: Bool {
            true
        }
    }
}
