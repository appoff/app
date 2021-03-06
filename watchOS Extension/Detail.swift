import SwiftUI
import Offline

struct Detail: View {
    let project: Project
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                if let thumbnail = project.schema.flatMap { UIImage(data: $0.thumbnail) } {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "cloud")
                        .font(.system(size: 50, weight: .light))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                        .padding(.top, 30)
                        .padding(.bottom)
                }
                
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 28, weight: .light))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .black)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .frame(width: 65, height: 65)
                    Spacer()
                }
            }
            
            NavigationLink(destination: Lazy(Navigate(schema: project.schema!))) {
                Text("Open")
            }
            .font(.callout.weight(.medium))
            .tint(.white)
            .foregroundColor(.black)
            .buttonStyle(.borderedProminent)
            .padding()
            
            Text(project.header.title)
                .font(.callout)
                .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            Item(title: "Origin", content: .init(project.header.origin))
            Item(title: "Destination", content: .init(project.header.destination))
            Item(title: "Distance", content: .init(Measurement(value: .init(project.header.distance), unit: UnitLength.meters),
                                                   format: .measurement(width: .abbreviated)))
            Item(title: "Duration", content: .init(Date(timeIntervalSinceNow: -.init(project.header.duration)) ..< Date.now, format: .timeDuration))
            
            Spacer()
                .frame(height: 30)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}
