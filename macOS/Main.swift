import AppKit
import Combine
import Coffee

final class Main: NSView {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let logo = NSImageView(image: .init(named: "Logo") ?? .init())
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.imageScaling = .scaleNone
        logo.isHidden = true
        addSubview(logo)
        
        let image = NSView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer = .init()
        image.layer!.contentsGravity = .resizeAspectFill
        image.wantsLayer = true
        image.isHidden = true
        addSubview(image)
        
        let separator = Separator()
        separator.isHidden = true
        addSubview(separator)
        
        var info: Info?
        
        logo.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logo.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        image.topAnchor.constraint(equalTo: topAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        image.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        image.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.topAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        session
            .selected
            .sink { selected in
                if let selected = selected {
                    logo.isHidden = true
                    separator.isHidden = false
                    
                    if let thumbnail = selected.schema.flatMap({ NSImage(data: $0.thumbnail) }) {
                        image.layer!.contents = thumbnail
                        image.isHidden = false
                    }
                    
                    info = .init(session: session, header: selected.header, full: true)
                    self.addSubview(info!)
                    
                    info!.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 15).isActive = true
                    info!.leftAnchor.constraint(equalTo: separator.leftAnchor, constant: 10).isActive = true
                    info!.rightAnchor.constraint(equalTo: separator.rightAnchor, constant: -10).isActive = true
                } else {
                    logo.isHidden = false
                    image.isHidden = true
                    separator.isHidden = true
                    info?.removeFromSuperview()
                }
            }
            .store(in: &subs)
    }
    
    override var allowsVibrancy: Bool {
        true
    }
}
