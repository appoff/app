import SwiftUI
import Offline

extension Main {
    struct Item: View {
        let session: Session
        let map: Offline.Map
        
        var body: some View {
            Button {
                
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.tertiarySystemBackground))
                        .frame(height: 460)
                        .shadow(color: .init(white: 0, opacity: 0.1), radius: 8, y: 6)
                    VStack(spacing: 0) {
                        Image(systemName: "map")
                            .font(.system(size: 30, weight: .light))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .greatestFiniteMagnitude, maxHeight: .greatestFiniteMagnitude)
                        VStack(alignment: .leading) {
                            Text(map.title)
                                .font(.body.weight(.medium))
                                .fixedSize(horizontal: false, vertical: true)
                            Info(title: "Origin", content: .init(map.origin))
                            Info(title: "Destination", content: .init(map.destination))
                            HStack {
                                VStack(alignment: .leading) {
                                    Info(title: "Duration", content: .init(Date(timeIntervalSinceNow: -.init(map.duration)) ..< Date.now, format: .timeDuration))
                                }
                                VStack(alignment: .leading) {
                                    Info(title: "Distance", content: .init(Measurement(value: .init(map.distance), unit: UnitLength.meters),
                                                                           format: .measurement(width: .abbreviated)))
                                }
                            }
                        }
                        .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                        .padding([.leading, .trailing, .bottom])
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 10)
        }
    }
}
