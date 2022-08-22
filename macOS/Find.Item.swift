import MapKit
import Combine
import Coffee

extension Find {
    final class Item: NSView {
        private var subs = Set<AnyCancellable>()
        
        required init?(coder: NSCoder) { nil }
        init(item: MKLocalSearchCompletion,
             select: PassthroughSubject<MKLocalSearchCompletion, Never>,
             complete: PassthroughSubject<String, Never>) {
            
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let result = Control.Empty()
            result
                .click
                .sink { [weak self] in
                    select.send(item)
                    self?.window?.close()
                }
                .store(in: &subs)
            addSubview(result)
            
            let autocomplete = Control.Symbol(symbol: "character.cursor.ibeam", size: 14)
            autocomplete.toolTip = "Search for a map"
            autocomplete
                .click
                .sink {
                    complete.send(item.title)
                }
                .store(in: &subs)
            addSubview(autocomplete)
            
            let string = NSMutableAttributedString()
            let title = NSMutableAttributedString()
            title.append(.init(string: item.title,
                               attributes: [
                                .font: NSFont.systemFont(
                                    ofSize: NSFont.preferredFont(forTextStyle: .title3).pointSize,
                                    weight: .regular),
                                .foregroundColor: NSColor.secondaryLabelColor]))
            
            item
                .titleHighlightRanges
                .forEach { value in
                    title.setAttributes([.foregroundColor: NSColor.labelColor,
                                         .font: NSFont.systemFont(
                                            ofSize: NSFont.preferredFont(forTextStyle: .title3).pointSize,
                                            weight: .bold)],
                                        range: value.rangeValue)
                }
            
            string.append(title)
            
            if !item.subtitle.isEmpty {
                string.append(.init(string: "\n"))
                
                let subtitle = NSMutableAttributedString()
                subtitle.append(.init(string: item.subtitle,
                                      attributes: [
                                        .font: NSFont.systemFont(
                                            ofSize: NSFont.preferredFont(forTextStyle: .body).pointSize,
                                            weight: .regular),
                                        .foregroundColor: NSColor.secondaryLabelColor]))
                
                item
                    .subtitleHighlightRanges
                    .forEach { value in
                        subtitle.setAttributes([.font: NSFont.systemFont(
                                                ofSize: NSFont.preferredFont(forTextStyle: .body).pointSize,
                                                weight: .bold)],
                                            range: value.rangeValue)
                    }
                
                string.append(subtitle)
            }
            
            let text = Text(vibrancy: false)
            text.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            text.attributedStringValue = string
            addSubview(text)
            
            let separator = Separator()
            addSubview(separator)
            
            widthAnchor.constraint(equalToConstant: 398).isActive = true
            bottomAnchor.constraint(equalTo: text.bottomAnchor, constant: 11).isActive = true
            
            result.topAnchor.constraint(equalTo: topAnchor).isActive = true
            result.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            result.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            result.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
            
            autocomplete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            autocomplete.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
            
            text.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            text.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            text.rightAnchor.constraint(equalTo: autocomplete.leftAnchor, constant: -10).isActive = true
            
            separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
    }
}
