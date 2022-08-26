import AppKit
import Coffee
import Combine
import Offline

private let rotation = Double.pi / 10
private let offsetting = Double(5)

final class Loading: NSView {
    private weak var image: NSImageView!
    private var subs = Set<AnyCancellable>()
    private let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, factory: Factory) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        var waiting = true
        var error = false
        
        let image = NSImageView(image: .init(named: "Loading") ?? .init())
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentTintColor = .secondaryLabelColor
        image.wantsLayer = true
        addSubview(image)
        self.image = image
        
        let base = NSView()
        base.wantsLayer = true
        base.translatesAutoresizingMaskIntoConstraints = false
        base.layer!.backgroundColor = NSColor.unemphasizedSelectedTextBackgroundColor.cgColor
        base.layer!.cornerRadius = 5
        addSubview(base)
        
        let progress = NSView()
        progress.wantsLayer = true
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.layer!.backgroundColor = NSColor.labelColor.cgColor
        progress.layer!.cornerRadius = 7
        addSubview(progress)
        
        let header = Text(vibrancy: false)
        header.stringValue = "Loading"
        header.font = .preferredFont(forTextStyle: .title1)
        header.textColor = .secondaryLabelColor
        addSubview(header)
        
        let title = Text(vibrancy: false)
        title.stringValue = factory.header.title
        title.font = .preferredFont(forTextStyle: .title3)
        title.textColor = .tertiaryLabelColor
        addSubview(title)
        
        let warning = NSImageView(image: .init(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil) ?? .init())
        warning.isHidden = true
        warning.translatesAutoresizingMaskIntoConstraints = false
        warning.symbolConfiguration = .init(pointSize: 50, weight: .ultraLight)
            .applying(.init(hierarchicalColor: .secondaryLabelColor))
        addSubview(warning)
        
        let fail = Text(vibrancy: false)
        fail.isHidden = true
        fail.textColor = .secondaryLabelColor
        fail.font = .preferredFont(forTextStyle: .title2)
        fail.stringValue = "Loading failed"
        addSubview(fail)
        
        let tryAgain = Control.Prominent(title: "Try again")
        tryAgain.toolTip = "Try loading map again"
        tryAgain.state = .hidden
        tryAgain
            .click
            .sink {
                error = false
                Task {
                    await factory.shoot()
                }
            }
            .store(in: &subs)
        addSubview(tryAgain)
        
        let cancel = Control.Plain(title: "Cancel")
        cancel.toolTip = "Cancel loading"
        cancel
            .click
            .sink { [weak self] in
                let alert = NSAlert()
                alert.alertStyle = .warning
                alert.icon = .init(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: nil)
                alert.messageText = "Stop loading map?"
                
                let stop = alert.addButton(withTitle: "Stop")
                let cont = alert.addButton(withTitle: "Continue")
                stop.hasDestructiveAction = true
                stop.keyEquivalent = "\r"
                cont.keyEquivalent = "\u{1b}"
                
                if alert.runModal().rawValue == stop.tag {
                    factory.cancel()
                    session.flow.value = .main
                    self?.window?.makeFirstResponder(self?.window?.contentView)
                }
            }
            .store(in: &subs)
        addSubview(cancel)
        
        image.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 51).isActive = true
        
        base.widthAnchor.constraint(equalToConstant: 160).isActive = true
        base.heightAnchor.constraint(equalToConstant: 10).isActive = true
        base.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 25).isActive = true
        
        progress.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        progress.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        progress.heightAnchor.constraint(equalToConstant: 14).isActive = true
        let progressWidth = progress.widthAnchor.constraint(equalToConstant: 0)
        progressWidth.isActive = true
        
        header.topAnchor.constraint(equalTo: progress.bottomAnchor, constant: 42).isActive = true
        
        title.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 4).isActive = true
        
        warning.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        
        fail.topAnchor.constraint(equalTo: warning.bottomAnchor, constant: 20).isActive = true
        
        tryAgain.topAnchor.constraint(equalTo: fail.bottomAnchor, constant: 40).isActive = true
        tryAgain.widthAnchor.constraint(equalToConstant: 120).isActive = true
        tryAgain.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        cancel.topAnchor.constraint(equalTo: tryAgain.bottomAnchor, constant: 20).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        [base, header, title, warning, fail, tryAgain, cancel]
            .forEach {
                $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            }
        
        factory
            .fail
            .sink {
                error = true
                header.isHidden = true
                title.isHidden = true
                warning.isHidden = false
                fail.isHidden = false
                tryAgain.state = .on
            }
            .store(in: &subs)
        
        factory
            .progress
            .sink {
                progressWidth.constant = max(160 * $0, 14)
            }
            .store(in: &subs)
        
        factory
            .finished
            .sink { schema in
                session.review()
                
                Task {
                    await cloud.add(header: factory.header, schema: schema)
                    session.flow.value = .created(factory.header)
                }
            }
            .store(in: &subs)
        
        timer
            .sink { [weak self] _ in
                image.layer!.anchorPoint = .init(x: 0.5, y: 0)
                
                guard waiting, !error else { return }
                
                switch Int.random(in: 0 ..< 80) {
                case 0:
                    waiting = false
                    self?.animate(rotation: rotation)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.animate(rotation: -rotation)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.animate(rotation: 0)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        waiting = true
                    }
                case 1:
                    waiting = false
                    
                    self?.animate(offset: offsetting)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self?.animate(offset: -offsetting)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self?.animate(offset: 0)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        waiting = true
                    }
                default:
                    break
                }
            }
            .store(in: &subs)
        
        Task {
            await factory.shoot()
        }
    }
    
    override var allowsVibrancy: Bool {
        true
    }
    
    private func animate(rotation: Double) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = rotation
        animation.duration = 0.5
        animation.timingFunction = .init(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = true
        image.layer!.add(animation, forKey: "transform")
    }
    
    private func animate(offset: Double) {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.toValue = offset
        animation.duration = 0.5
        animation.timingFunction = .init(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = true
        image.layer!.add(animation, forKey: "transform")
    }
}
