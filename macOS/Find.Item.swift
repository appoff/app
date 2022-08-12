import MapKit
import Combine
import Coffee

extension Find {
    final class Item: Control {
        required init?(coder: NSCoder) { nil }
        init(item: MKLocalSearchCompletion,
             select: PassthroughSubject<MKLocalSearchCompletion, Never>,
             complete: PassthroughSubject<String, Never>) {
            
            super.init(layer: true)
        }
        
        override func updateLayer() {
            super.updateLayer()
            
            NSApp
                .effectiveAppearance
                .performAsCurrentDrawingAppearance {
//                    switch state {
//                    case .highlighted, .pressed, .selected:
//                        background.layer!.backgroundColor = NSColor.labelColor.withAlphaComponent(0.07).cgColor
//                    default:
//                        background.layer!.backgroundColor = .clear
//                    }
                }
        }
    }
}

/*
 import SwiftUI
 import MapKit

 extension Find {
     struct Item: View {
         let item: MKLocalSearchCompletion
         let complete: () -> Void
         let action: () -> Void
         
         var body: some View {
             Button(action: action) {
                 HStack {
                     Text(title)
                     + complement
                     Spacer()
                     Button(action: complete) {
                         Image(systemName: "character.cursor.ibeam")
                             .font(.system(size: 16, weight: .medium))
                             .foregroundColor(.primary)
                             .frame(width: 34, height: 34)
                             .contentShape(Rectangle())
                     }
                 }
                 .fixedSize(horizontal: false, vertical: true)
                 .padding(.vertical, 5)
                 .contentShape(Rectangle())
             }
         }
         
         private var title: AttributedString {
             var string = AttributedString(item.title, attributes: .init([
                 .font: UIFont.preferredFont(forTextStyle: .callout),
                 .foregroundColor: UIColor.secondaryLabel]))
             
             item
                 .titleHighlightRanges
                 .forEach { value in
                     let substring = item.title[item.title.index(item.title.startIndex, offsetBy: value.rangeValue.lowerBound) ..< item.title.index(item.title.startIndex, offsetBy: value.rangeValue.upperBound)]
                     if let range = string.range(of: substring) {
                         string[range].foregroundColor = UIColor.label
                         string[range].font = .callout.bold()
                     }
                 }
             
             return string
         }
         
         private var complement: Text {
             if item.subtitle.isEmpty {
                 return Text("")
             } else {
                 return Text("\n")
                 + Text(subtitle)
             }
         }
         
         private var subtitle: AttributedString {
             var string = AttributedString(item.subtitle, attributes: .init([
                 .font: UIFont.preferredFont(forTextStyle: .footnote),
                 .foregroundColor: UIColor.secondaryLabel]))
             
             item
                 .subtitleHighlightRanges
                 .forEach { value in
                     let substring = item.subtitle[item.subtitle.index(item.subtitle.startIndex, offsetBy: value.rangeValue.lowerBound) ..< item.subtitle.index(item.subtitle.startIndex, offsetBy: value.rangeValue.upperBound)]
                     if let range = string.range(of: substring) {
                         string[range].font = .footnote.bold()
                     }
                 }
             
             return string
         }
     }
 }

 */
