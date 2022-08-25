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
        
        let create = Control.Button(symbol: "plus")
        create.toolTip = "New map"
        create
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.flow.value = .create
            }
            .store(in: &subs)
        
        let scan = Control.Button(symbol: "square.and.arrow.down")
        scan.toolTip = "Import map"
        scan
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.flow.value = .scan
            }
            .store(in: &subs)
        
        let trash = Control.Button(symbol: "trash")
        trash.color = .systemPink
        trash.toolTip = "Delete map"
        trash
            .click
            .sink { [weak self] in
                guard case .main = session.flow.value, session.selected.value != nil else { return }
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.trash.send()
            }
            .store(in: &subs)
        
        let cancel = Control.Button(symbol: "xmark")
        cancel.toolTip = "Cancel new map"
        cancel
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.cancel.send(nil)
            }
            .store(in: &subs)
        
        let help = Control.Button(symbol: "questionmark.circle")
        help.toolTip = "Help"
        help
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.help.send(help)
            }
            .store(in: &subs)
        
        let options = Control.Button(symbol: "slider.horizontal.3")
        options.toolTip = "Options"
        options
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.options.send(options)
            }
            .store(in: &subs)
        
        let find = Control.Button(symbol: "magnifyingglass")
        find.toolTip = "Find place"
        find
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.find.send()
            }
            .store(in: &subs)
        
        let settings = Control.Button(symbol: "square.stack.3d.up")
        settings.toolTip = "Settings"
        settings
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.settings.send(settings)
            }
            .store(in: &subs)
        
        let follow = Control.Button(symbol: "location.viewfinder")
        follow.toolTip = "My location"
        follow
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.follow.send()
            }
            .store(in: &subs)
        
        let save = Control.Prominent(title: "Save", radius: 13)
        save.toolTip = "Save new map"
        save
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.save.send()
            }
            .store(in: &subs)
        
        let share = Control.Prominent(title: "Share")
        share.toolTip = "Share map"
        share
            .click
            .sink {
                session.share.send()
            }
            .store(in: &subs)
        
        let offload = Control.Prominent(title: "Offload")
        offload.toolTip = "Offload map"
        offload
            .click
            .sink {
                session.offload.send()
            }
            .store(in: &subs)
        
        [save, share, offload]
            .forEach {
                $0.color = .labelColor
                $0.text.textColor = .windowBackgroundColor
                
                $0.widthAnchor.constraint(equalToConstant: 90).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 26).isActive = true
            }
        
        [create, scan, cancel, help, options, find, settings, follow, save, trash, share, offload]
            .forEach {
                $0.state = .hidden
                addSubview($0)
                
                $0.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            }
        
        create.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        scan.leftAnchor.constraint(equalTo: create.rightAnchor, constant: 10).isActive = true
        
        share.leftAnchor.constraint(equalTo: scan.rightAnchor, constant: 160).isActive = true
        offload.leftAnchor.constraint(equalTo: share.rightAnchor, constant: 10).isActive = true
        
        save.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        follow.rightAnchor.constraint(equalTo: save.leftAnchor, constant: -15).isActive = true
        find.rightAnchor.constraint(equalTo: follow.leftAnchor, constant: -10).isActive = true
        settings.rightAnchor.constraint(equalTo: find.leftAnchor, constant: -10).isActive = true
        
        options.rightAnchor.constraint(equalTo: settings.leftAnchor, constant: -10).isActive = true
        help.rightAnchor.constraint(equalTo: options.leftAnchor, constant: -10).isActive = true
        cancel.rightAnchor.constraint(equalTo: help.leftAnchor, constant: -10).isActive = true
        
        trash.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        
        session
            .flow
            .combineLatest(session
                .premium
                .removeDuplicates(),
                           session
                .selected
                .removeDuplicates {
                    $0?.id == $1?.id
                },
                           session
                .ready
                .removeDuplicates())
            .sink { flow, premium, selected, completed in
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
                    trash.state = selected == nil ? .hidden : .on
                    share.state = selected != nil && premium ? .on : .hidden
                    offload.state = selected != nil && premium ? .on : .hidden
                case .create:
                    create.state = .hidden
                    scan.state = .hidden
                    cancel.state = .on
                    help.state = .on
                    options.state = .on
                    find.state = .on
                    settings.state = .on
                    follow.state = .on
                    save.state = completed ? .on : .off
                    trash.state = .hidden
                    share.state = .hidden
                    offload.state = .hidden
                default:
                    create.state = .hidden
                    scan.state = .hidden
                    cancel.state = .hidden
                    help.state = .hidden
                    options.state = .hidden
                    find.state = .hidden
                    settings.state = .hidden
                    follow.state = .hidden
                    save.state = .hidden
                    trash.state = .hidden
                    share.state = .hidden
                    offload.state = .hidden
                }
            }
            .store(in: &subs)
    }
    
    override func acceptsFirstMouse(for: NSEvent?) -> Bool {
        true
    }
}
