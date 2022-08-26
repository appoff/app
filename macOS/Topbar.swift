import AppKit
import Coffee
import Combine

private let spacing = CGFloat(15)

final class Topbar: NSView {
    private var subs = Set<AnyCancellable>()
    private let session: Session
    
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        self.session = session
        super.init(frame: .zero)
        
        let title = Text(vibrancy: true)
        title.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .title3).pointSize, weight: .medium)
        title.textColor = .labelColor
        title.maximumNumberOfLines = 1
        title.lineBreakMode = .byTruncatingTail
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        
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
        
        let points = Control.Button(symbol: "arrow.triangle.turn.up.right.circle")
        points.toolTip = "Directions"
        points
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
        
        let open = Control.Prominent(title: "Open")
        open.toolTip = "Open map"
        open
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.open.send()
            }
            .store(in: &subs)
        
        let share = Control.Prominent(title: "Share")
        share.toolTip = "Share map"
        share
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.share.send()
            }
            .store(in: &subs)
        
        let offload = Control.Prominent(title: "Offload")
        offload.toolTip = "Offload map"
        offload
            .click
            .sink { [weak self] in
                self?.window?.makeFirstResponder(self?.window?.contentView)
                session.offload.send()
            }
            .store(in: &subs)
        
        let stack = Stack()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = spacing
        stack.orientation = .horizontal
        
        [save, share, offload, open]
            .forEach {
                $0.widthAnchor.constraint(equalToConstant: 90).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 26).isActive = true
            }
        
        [save, open]
            .forEach {
                $0.color = .labelColor
                $0.text.textColor = .windowBackgroundColor
            }
        
        [create, scan, title, stack]
            .forEach {
                addSubview($0)
                $0.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            }
        
        create.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: spacing).isActive = true
        scan.leftAnchor.constraint(equalTo: create.rightAnchor, constant: spacing).isActive = true

        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 205).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: stack.leftAnchor, constant: -5).isActive = true
        
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -spacing).isActive = true
        
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
                var views = [Control]()
                
                switch flow {
                case .main:
                    title.stringValue = ""
                    if selected != nil {
                        views = [trash] + (premium ? [share, offload] : []) + [open]
                    }
                case .create:
                    title.stringValue = "Create map"
                    save.state = completed ? .on : .off
                    views = [cancel, help, options, settings, find, follow, save]
                case .navigate:
                    title.stringValue = session.selected.value?.header.title ?? ""
                    views = [settings, points, follow]
                default:
                    title.stringValue = ""
                    break
                }
                
                stack.setViews(views, in: .center)
            }
            .store(in: &subs)
    }
    
    override func acceptsFirstMouse(for: NSEvent?) -> Bool {
        true
    }
}
