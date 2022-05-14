import SwiftUI
import Offline

struct Info: View {
    let map: Offline.Map
    let constrain: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(map.title)
                .font(.title.bold())
                .lineLimit(constrain ? 1 : nil)
                .offset(y: 8)
                .padding(.top, 8)
            Item(title: "Origin", content: .init(map.origin))
            Item(title: "Destination", content: .init(map.destination))
            HStack {
                VStack(alignment: .leading) {
                    Item(title: "Duration", content: .init(Date(timeIntervalSinceNow: -.init(map.duration)) ..< Date.now, format: .timeDuration))
                }
                VStack(alignment: .leading) {
                    Item(title: "Distance", content: .init(Measurement(value: .init(map.distance), unit: UnitLength.meters),
                                                           format: .measurement(width: .abbreviated)))
                }
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
    }
}
