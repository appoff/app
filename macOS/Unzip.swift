import AppKit
import Coffee
import Combine
import Offline

final class Unzip: NSView {
    private var subs = Set<AnyCancellable>()

    required init?(coder: NSCoder) { nil }
    init(session: Session, project: Project) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = NSImageView(image: .init(systemSymbolName: "doc.zipper", accessibilityDescription: nil) ?? .init())
        image.translatesAutoresizingMaskIntoConstraints = false
        image.symbolConfiguration = .init(pointSize: 60, weight: .ultraLight)
            .applying(.init(hierarchicalColor: .labelColor))
        image.contentTintColor = .labelColor
        
        let title = Text(vibrancy: false)
        title.stringValue = "Loading"
        title.font = .preferredFont(forTextStyle: .title1)
        title.textColor = .labelColor
        
        let subtitle = Text(vibrancy: false)
        subtitle.stringValue = project.header.title
        subtitle.font = .preferredFont(forTextStyle: .title3)
        subtitle.textColor = .secondaryLabelColor
        subtitle.maximumNumberOfLines = 1
        subtitle.lineBreakMode = .byTruncatingTail
        
        [image, title, subtitle]
            .forEach {
                addSubview($0)
                $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            }
        
        image.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 45).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 30).isActive = true
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        subtitle.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        
        Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            
            guard let bufferer = project.bufferer else { return }
            session.flow.value = .navigate(project.schema!, bufferer)
        }
    }
    
    override var allowsVibrancy: Bool {
        true
    }
}


/*
 let session: Session
 let project: Project
 
 var body: some View {
     VStack {
         Spacer()
         
         Image(systemName: "doc.zipper")
             .font(.system(size: 60, weight: .ultraLight))
             .symbolRenderingMode(.hierarchical)
             .foregroundStyle(.primary)
         
         Text("Loading")
             .font(.title2.weight(.regular))
             .padding(.top)
         
         Text(project.header.title)
             .font(.callout)
             .foregroundStyle(.secondary)
             .lineLimit(1)
             .frame(maxWidth: 280)
         
         Spacer()
     }
     .task {
         try? await Task.sleep(nanoseconds: 450_000_000)
         session.selected = nil
         
         guard let bufferer = project.bufferer else { return }
         
         withAnimation(.easeOut(duration: 0.5)) {
             session.flow = .navigate(project.schema!, bufferer)
         }
     }
 }
 */
