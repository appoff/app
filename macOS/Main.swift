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
        
        var info: Info?
        
        logo.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logo.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        session
            .selected
            .sink { selected in
                info?.removeFromSuperview()
                
                if let selected = selected {
                    logo.isHidden = true
                    
                    info = .init(session: session, header: selected.header, full: true)
                    self.addSubview(info!)
                    
                    info!.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
                    info!.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 40).isActive = true
                    info!.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -40).isActive = true
                } else {
                    logo.isHidden = false
                }
            }
            .store(in: &subs)
    }
    
    override var allowsVibrancy: Bool {
        true
    }
}
