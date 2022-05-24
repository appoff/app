import SwiftUI
import Offline

struct Info: View {
    let header: Header
    let size: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(header.title)
                .font(.title2.bold())
                .offset(y: 8)
                .padding(.top, 8)
            Item(title: "Origin", content: .init(header.origin))
            Item(title: "Destination", content: .init(header.destination))
            if size > 0 {
                HStack {
                    VStack(alignment: .leading) {
                        Item(title: "Duration", content: .init(Date(timeIntervalSinceNow: -.init(header.duration)) ..< Date.now, format: .timeDuration))
                    }
                    VStack(alignment: .leading) {
                        Item(title: "Distance", content: .init(Measurement(value: .init(header.distance), unit: UnitLength.meters),
                                                               format: .measurement(width: .abbreviated)))
                    }
                    VStack(alignment: .leading) {
                        Item(title: "Size", content: .init(.init(size), format: .byteCount(style: .file)))
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
