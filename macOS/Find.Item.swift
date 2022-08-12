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
            addSubview(result)
            
            let autocomplete = Control.Symbol(symbol: "character.cursor.ibeam", size: 14)
            addSubview(autocomplete)
            
            let string = NSMutableAttributedString()
            let title = NSMutableAttributedString()
            title.append(.init(string: item.title,
                               attributes: [
                                .font: NSFont.systemFont(
                                    ofSize: NSFont.preferredFont(forTextStyle: .body).pointSize,
                                    weight: .regular),
                                .foregroundColor: NSColor.secondaryLabelColor]))
            
            item
                .titleHighlightRanges
                .forEach { value in
                    title.setAttributes([.foregroundColor: NSColor.labelColor,
                                         .font: NSFont.systemFont(
                                            ofSize: NSFont.preferredFont(forTextStyle: .body).pointSize,
                                            weight: .bold)],
                                        range: value.rangeValue)
                }
            
            string.append(title)
            
            if !item.subtitle.isEmpty {
                string.append(.init(string: "\n"))
                
                let subtitle = NSMutableAttributedString()
                subtitle.append(.init(string: item.title,
                                      attributes: [
                                        .font: NSFont.systemFont(
                                            ofSize: NSFont.preferredFont(forTextStyle: .callout).pointSize,
                                            weight: .regular),
                                        .foregroundColor: NSColor.secondaryLabelColor]))
                
                item
                    .subtitleHighlightRanges
                    .forEach { value in
                        title.setAttributes([.font: NSFont.systemFont(
                                                ofSize: NSFont.preferredFont(forTextStyle: .callout).pointSize,
                                                weight: .bold)],
                                            range: value.rangeValue)
                    }
                
                string.append(subtitle)
            }
            
            let text = Text(vibrancy: false)
            text.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            text.attributedStringValue = string
            addSubview(text)
            
            widthAnchor.constraint(equalToConstant: 398).isActive = true
            bottomAnchor.constraint(equalTo: text.bottomAnchor, constant: 10).isActive = true
            
            result.topAnchor.constraint(equalTo: topAnchor).isActive = true
            result.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            result.rightAnchor.constraint(equalTo: autocomplete.leftAnchor).isActive = true
            result.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            autocomplete.topAnchor.constraint(equalTo: topAnchor).isActive = true
            autocomplete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            autocomplete.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            text.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            text.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
            text.rightAnchor.constraint(equalTo: autocomplete.rightAnchor, constant: -10).isActive = true
        }
    }
}
