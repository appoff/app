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
        
        let scroll = Scroll()
        scroll.isHidden = true
        scroll.contentView.postsBoundsChangedNotifications = false
        scroll.contentView.postsFrameChangedNotifications = false
        addSubview(scroll)
        
        var info: Info?
        
        let upgrade = Upgrade()
        upgrade.isHidden = true
        scroll.documentView!.addSubview(upgrade)
        
        logo.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logo.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        scroll.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        upgrade.centerXAnchor.constraint(equalTo: scroll.documentView!.centerXAnchor).isActive = true
        
        session
            .selected
            .combineLatest(session.premium)
            .sink { selected, premium in
                info?.removeFromSuperview()
                
                if let selected = selected {
                    logo.isHidden = true
                    scroll.isHidden = false
                    
                    info = .init(session: session, header: selected.header, full: true)
                    scroll.documentView!.addSubview(info!)
                    
                    if premium {
                        upgrade.isHidden = true
                        
                        scroll.documentView!.bottomAnchor.constraint(equalTo: info!.bottomAnchor, constant: 40).isActive = true
                    } else {
                        upgrade.isHidden = false
                        
                        upgrade.topAnchor.constraint(equalTo: info!.bottomAnchor, constant: 40).isActive = true
                        scroll.documentView!.bottomAnchor.constraint(equalTo: upgrade.bottomAnchor, constant: 40).isActive = true
                    }
                    
                    info!.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
                    info!.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 40).isActive = true
                    info!.rightAnchor.constraint(equalTo: scroll.rightAnchor, constant: -40).isActive = true
                } else {
                    logo.isHidden = false
                    scroll.isHidden = true
                }
            }
            .store(in: &subs)
        
        session
            .trash
            .sink { [weak self] in
                guard let selected = session.selected.value else { return }
                
                let alert = NSAlert()
                alert.alertStyle = .warning
                alert.icon = .init(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: nil)
                alert.messageText = "Delete map?"
                
                let delete = alert.addButton(withTitle: "Delete")
                let cont = alert.addButton(withTitle: "Cancel")
                delete.hasDestructiveAction = true
                delete.keyEquivalent = "\r"
                cont.keyEquivalent = "\u{1b}"
                
                if alert.runModal().rawValue == delete.tag {
                    session.flow.value = .deleted(selected.header)
                    self?.window?.makeFirstResponder(self?.window?.contentView)
                }
            }
            .store(in: &subs)
        
        session
            .share
            .sink {
                guard let selected = session.selected.value else { return }
                session.flow.value = .share(selected.header)
            }
            .store(in: &subs)
        
        session
            .offload
            .sink {
                guard let selected = session.selected.value else { return }
                session.flow.value = .offload(selected.header)
            }
            .store(in: &subs)
    }
    
    override var allowsVibrancy: Bool {
        true
    }
}
