import SwiftUI
import Offline

extension Main {
    struct Item: View {
        let session: Session
        let map: Offline.Map
        @State private var thumbnail: UIImage?
        
        var body: some View {
            Button {
                
            } label: {
                ZStack {
                    Rectangle()
                        .fill(Color(.tertiarySystemBackground))
                    VStack(spacing: 0) {
                        ZStack {
                            if let thumbnail = thumbnail {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .scaledToFill()
    //                                    .frame(height: 200, alignment: .center)
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                            } else {
                                Image(systemName: "map")
                                    .font(.system(size: 30, weight: .light))
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.secondary)
                                    .frame(height: 120)
                                    .frame(maxWidth: .greatestFiniteMagnitude)
                            }
                            
                            Text(map.title)
                                .font(.title2.bold())
                                .lineLimit(1)
                                .padding()
                                .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                                .background(Color(.tertiarySystemBackground))
                                .frame(maxHeight: .greatestFiniteMagnitude, alignment: .bottom)
                        }

                        VStack(alignment: .leading) {
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
                        .padding([.leading, .trailing, .bottom])
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .init(white: 0, opacity: 0.1), radius: 8, y: 6)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 10)
            .task {
                guard
                    let data = await cloud.model.thumbnails[map.id],
                    let image = UIImage(data: data)
                else { return }
                thumbnail = image
            }
        }
    }
}
