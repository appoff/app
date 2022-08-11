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
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.flow.value = .create
            }
            .store(in: &subs)
        addSubview(create)
        
        let scan = Button(symbol: "square.and.arrow.down")
        scan.toolTip = "Import map"
        scan
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.flow.value = .scan
            }
            .store(in: &subs)
        addSubview(scan)
        
        let cancel = Button(symbol: "xmark")
        cancel.toolTip = "Cancel new map"
        cancel.state = .hidden
        cancel
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.cancel.send()
            }
            .store(in: &subs)
        addSubview(cancel)
        
        let help = Button(symbol: "questionmark.circle")
        help.toolTip = "Help"
        help.state = .hidden
        help
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                
            }
            .store(in: &subs)
        addSubview(help)
        
        let options = Button(symbol: "slider.horizontal.3")
        options.toolTip = "Options"
        options.state = .hidden
        options
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.options.send(options)
            }
            .store(in: &subs)
        addSubview(options)
        
        let find = Button(symbol: "magnifyingglass")
        find.toolTip = "Find place"
        find.state = .hidden
        find
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.find.send()
            }
            .store(in: &subs)
        addSubview(find)
        
        let settings = Button(symbol: "square.stack.3d.up")
        settings.toolTip = "Settings"
        settings.state = .hidden
        settings
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.settings.send(settings)
            }
            .store(in: &subs)
        addSubview(settings)
        
        let follow = Button(symbol: "location.viewfinder")
        follow.toolTip = "My location"
        follow.state = .hidden
        follow
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.follow.send()
            }
            .store(in: &subs)
        addSubview(follow)
        
        let save = Control.Main(title: "Save")
        save.color = .labelColor
        save.text.textColor = .windowBackgroundColor
        save.state = .hidden
        save.toolTip = "Save new map"
        save.widthAnchor.constraint(equalToConstant: 68).isActive = true
        save
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                
            }
            .store(in: &subs)
        addSubview(save)
        
        create.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        scan.leftAnchor.constraint(equalTo: create.rightAnchor, constant: 10).isActive = true
        
        save.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        follow.rightAnchor.constraint(equalTo: save.leftAnchor, constant: -15).isActive = true
        find.rightAnchor.constraint(equalTo: follow.leftAnchor, constant: -10).isActive = true
        settings.rightAnchor.constraint(equalTo: find.leftAnchor, constant: -10).isActive = true
        
        options.rightAnchor.constraint(equalTo: settings.leftAnchor, constant: -10).isActive = true
        help.rightAnchor.constraint(equalTo: options.leftAnchor, constant: -10).isActive = true
        cancel.rightAnchor.constraint(equalTo: help.leftAnchor, constant: -10).isActive = true
        
        [create, scan, cancel, help, options, find, settings, follow, save]
            .forEach {
                $0.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            }
        
        session
            .flow
            .combineLatest(session.ready.removeDuplicates())
            .sink { flow, completed in
                switch flow {
                case .main:
                    create.state = .on
                    scan.state = .on
                    cancel.state = .hidden
                    help.state = .hidden
                    options.state = .hidden
                    find.state = .hidden
                    settings.state = .hidden
                    follow.state = .hidden
                    save.state = .hidden
                case .create:
                    create.state = .off
                    scan.state = .off
                    cancel.state = .on
                    help.state = .on
                    options.state = .on
                    find.state = .on
                    settings.state = .on
                    follow.state = .on
                    save.state = completed ? .on : .off
                default:
                    create.state = .off
                    scan.state = .off
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
                    self?.window?.makeFirstResponder(self?.window?.contentView)
                }
            }
            .store(in: &subs)
    }
    
    override func acceptsFirstMouse(for: NSEvent?) -> Bool {
        true
    }
}
