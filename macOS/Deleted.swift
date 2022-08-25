import AppKit
import Coffee
import Combine
import Offline

final class Deleted: NSView {
    private var subs = Set<AnyCancellable>()

    required init?(coder: NSCoder) { nil }
    init(session: Session, header: Header) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = NSImageView(image: .init(named: "Deleted") ?? .init())
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentTintColor = .labelColor
        
        let title = Text(vibrancy: false)
        title.stringValue = "Deleted"
        title.font = .preferredFont(forTextStyle: .title1)
        title.textColor = .labelColor
        
        let subtitle = Text(vibrancy: false)
        subtitle.stringValue = header.title
        subtitle.font = .preferredFont(forTextStyle: .title3)
        subtitle.textColor = .secondaryLabelColor
        subtitle.maximumNumberOfLines = 1
        subtitle.lineBreakMode = .byTruncatingTail
        
        let accept = Control.Plain(title: "Continue")
        accept.toolTip = "Continue"
        accept
            .click
            .sink {
                session.flow.value = .main
            }
            .store(in: &subs)
        
        [image, title, subtitle, accept]
            .forEach {
                addSubview($0)
                $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            }
        
        image.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 45).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        subtitle.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        
        accept.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 50).isActive = true
        accept.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        Task {
            session.selected.value = nil
            
            await cloud.delete(header: header)
            session.local.delete(header: header)
        }
    }
    
    override var allowsVibrancy: Bool {
        true
    }
}
