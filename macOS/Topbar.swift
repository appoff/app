import AppKit
import Coffee
import Combine

final class Topbar: NSView {
    private var subs = Set<AnyCancellable>()
    private let session: Session
    
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        self.session = session
        super.init(frame: .zero)
        
        let create = Button(symbol: "plus")
        create.toolTip = "New map"
        create
            .click
            .sink {
                session.flow.value = .create
            }
            .store(in: &subs)
        addSubview(create)
        
        let scan = Button(symbol: "square.and.arrow.down")
        scan.toolTip = "Import map"
        scan
            .click
            .sink {
                session.flow.value = .scan
            }
            .store(in: &subs)
        addSubview(scan)
        
        let name = Field(session: session)
        name.isHidden = true
        addSubview(name)
        
        let rename = Button(symbol: "character.cursor.ibeam")
        rename.state = .hidden
        rename.toolTip = "Change name"
        rename
            .click
            .sink { [weak self] in
                guard case .create = session.flow.value else { return }
                self?.window?.makeFirstResponder(name)
            }
            .store(in: &subs)
        addSubview(rename)
        
        let cancel = Button(symbol: "xmark")
        cancel.toolTip = "Cancel new map"
        cancel.state = .hidden
        cancel
            .click
            .sink {
                session.cancel.send()
            }
            .store(in: &subs)
        addSubview(cancel)
        
        let help = Button(symbol: "questionmark.circle")
        help.toolTip = "Help"
        help.state = .hidden
        help
            .click
            .sink {
                
            }
            .store(in: &subs)
        addSubview(help)
        
        let config = Button(symbol: "slider.horizontal.3")
        config.toolTip = "config"
        config.state = .hidden
        config
            .click
            .sink {
                
            }
            .store(in: &subs)
        addSubview(config)
        
        let search = Button(symbol: "magnifyingglass")
        search.toolTip = "Find place"
        search.state = .hidden
        search
            .click
            .sink {
                
            }
            .store(in: &subs)
        addSubview(search)
        
        let options = Button(symbol: "square.stack.3d.up")
        options.toolTip = "Options"
        options.state = .hidden
        options
            .click
            .sink {
                
            }
            .store(in: &subs)
        addSubview(options)
        
        let follow = Button(symbol: "location.viewfinder")
        follow.toolTip = "Follow me"
        follow.state = .hidden
        follow
            .click
            .sink {
                
            }
            .store(in: &subs)
        addSubview(follow)
        
        let save = Control.Main(title: "Save")
        save.state = .hidden
        save.toolTip = "Save new map"
        save.widthAnchor.constraint(equalToConstant: 68).isActive = true
        save
            .click
            .sink {
                
            }
            .store(in: &subs)
        addSubview(save)
        
        create.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        scan.leftAnchor.constraint(equalTo: create.rightAnchor, constant: 10).isActive = true
        
        rename.leftAnchor.constraint(equalTo: leftAnchor, constant: 160).isActive = true
        name.leftAnchor.constraint(equalTo: rename.rightAnchor, constant: 8).isActive = true
        name.rightAnchor.constraint(lessThanOrEqualTo: cancel.leftAnchor, constant: -10).isActive = true
        let nameWidth = name.widthAnchor.constraint(equalToConstant: 200)
        nameWidth.priority = .defaultLow
        nameWidth.isActive = true
        
        save.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        follow.rightAnchor.constraint(equalTo: save.leftAnchor, constant: -15).isActive = true
        options.rightAnchor.constraint(equalTo: follow.leftAnchor, constant: -10).isActive = true
        search.rightAnchor.constraint(equalTo: options.leftAnchor, constant: -10).isActive = true
        config.rightAnchor.constraint(equalTo: search.leftAnchor, constant: -10).isActive = true
        help.rightAnchor.constraint(equalTo: config.leftAnchor, constant: -10).isActive = true
        cancel.rightAnchor.constraint(equalTo: help.leftAnchor, constant: -10).isActive = true
        
        [create, scan, rename, name, cancel, help, config, search, options, follow, save]
            .forEach {
                $0.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
                $0.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            }
        
        session
            .flow
            .sink {
                switch $0 {
                case .main:
                    create.state = .on
                    scan.state = .on
                    rename.state = .hidden
                    name.isHidden = true
                    cancel.state = .hidden
                    help.state = .hidden
                    config.state = .hidden
                    search.state = .hidden
                    options.state = .hidden
                    follow.state = .hidden
                    save.state = .hidden
                case .create:
                    create.state = .off
                    scan.state = .off
                    rename.state = .on
                    name.isHidden = false
                    cancel.state = .on
                    help.state = .on
                    config.state = .on
                    search.state = .on
                    options.state = .on
                    follow.state = .on
                    save.state = .off
                default:
                    create.state = .off
                    scan.state = .off
                    rename.state = .hidden
                    name.isHidden = true
                }
            }
            .store(in: &subs)
        
        session
            .cancel
            .sink { [weak self] in
                guard case .create = session.flow.value else { return }

                let alert = NSAlert()
                alert.alertStyle = .warning
                alert.icon = .init(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: nil)
                alert.messageText = "Cancel map?"
                
                let cancel = alert.addButton(withTitle: "Cancel")
                let cont = alert.addButton(withTitle: "Continue")
                cancel.keyEquivalent = "\r"
                cont.keyEquivalent = "\u{1b}"
                
                if alert.runModal().rawValue == cancel.tag {
                    session.flow.value = .main
                    name.stringValue = ""
                    self?.window?.makeFirstResponder(nil)
                }
            }
            .store(in: &subs)
    }
}
