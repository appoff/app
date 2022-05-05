import SwiftUI
import MapKit

extension Search {
    struct Item: View {
        let item: MKLocalSearchCompletion
        let complete: (String) -> Void
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text(title)
                    + Text("\n")
                    + Text(subtitle)
                    Spacer()
                    Button {
                        complete(item.title)
                    } label: {
                        Image(systemName: "character.cursor.ibeam")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
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
                .foregroundColor: UIColor.label]))
            
            item
                .titleHighlightRanges
                .forEach { value in
                    let substring = item.title[item.title.index(item.title.startIndex, offsetBy: value.rangeValue.lowerBound) ..< item.title.index(item.title.startIndex, offsetBy: value.rangeValue.upperBound)]
                    if let range = string.range(of: substring) {
                        string[range].font = .callout.bold()
                    }
                }
            
            return string
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
