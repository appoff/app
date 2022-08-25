import AppKit
import Coffee
import Combine
import Offline

final class Share: NSView {
    private var subs = Set<AnyCancellable>()
    private let syncher: Syncher
    private let error = PassthroughSubject<String, Never>()
    private let session: Session
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, header: Header) {
        self.session = session
        syncher = .init(header: header)
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = NSImageView(image: .init(systemSymbolName: "square.and.arrow.up", accessibilityDescription: nil) ?? .init())
        image.symbolConfiguration = .init(pointSize: 60, weight: .ultraLight)
            .applying(.init(hierarchicalColor: .labelColor))
        image.translatesAutoresizingMaskIntoConstraints = false
        
        let title = Text(vibrancy: false)
        title.stringValue = "Sharing"
        title.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .title1).pointSize, weight: .regular)
        
        let subtitle = Text(vibrancy: false)
        subtitle.stringValue = syncher.header.title
        subtitle.textColor = .secondaryLabelColor
        subtitle.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .title3).pointSize, weight: .regular)
        subtitle.maximumNumberOfLines = 1
        subtitle.lineBreakMode = .byTruncatingTail
        
        let warning = NSImageView(image: .init(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil) ?? .init())
        warning.symbolConfiguration = .init(pointSize: 50, weight: .ultraLight)
            .applying(.init(hierarchicalColor: .labelColor))
        warning.translatesAutoresizingMaskIntoConstraints = false
        warning.isHidden = true
        
        let fail = Text(vibrancy: false)
        fail.textColor = .secondaryLabelColor
        fail.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .title3).pointSize, weight: .regular)
        fail.alignment = .center
        fail.isHidden = true
        
        let please = Text(vibrancy: false)
        please.stringValue = "Please wait"
        please.textColor = .secondaryLabelColor
        please.font = .preferredFont(forTextStyle: .body)
        please.alignment = .center
        
        let tryAgain = Control.Prominent(title: "Try again")
        tryAgain.toolTip = "Try sharing again"
        tryAgain.state = .hidden
        tryAgain.color = .windowBackgroundColor
        tryAgain.text.textColor = .labelColor
        
        let cancel = Control.Plain(title: "Cancel")
        cancel.toolTip = "Cancel sharing"
        cancel.state = .hidden
        cancel
            .click
            .sink {
                session.flow.value = .main
            }
            .store(in: &subs)
        
        tryAgain
            .click
            .sink { [weak self] in
                title.isHidden = false
                warning.isHidden = true
                fail.stringValue = ""
                fail.isHidden = true
                please.isHidden = false
                tryAgain.state = .hidden
                cancel.state = .hidden
                
                Task { [weak self] in
                    await self?.share()
                }
            }
            .store(in: &subs)
        
        [image, title, subtitle, warning, fail, please, tryAgain, cancel]
            .forEach {
                addSubview($0)
                
                $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            }
        
        image.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 45).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 30).isActive = true
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        subtitle.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        warning.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 30).isActive = true
        fail.topAnchor.constraint(equalTo: warning.bottomAnchor, constant: 20).isActive = true
        please.topAnchor.constraint(equalTo: warning.topAnchor).isActive = true
        tryAgain.topAnchor.constraint(equalTo: fail.bottomAnchor, constant: 20).isActive = true
        tryAgain.widthAnchor.constraint(equalToConstant: 140).isActive = true
        tryAgain.heightAnchor.constraint(equalToConstant: 34).isActive = true
        cancel.topAnchor.constraint(equalTo: tryAgain.bottomAnchor, constant: 10).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 140).isActive = true
        
        error
            .sink {
                title.isHidden = true
                warning.isHidden = false
                fail.stringValue = $0
                fail.isHidden = false
                please.isHidden = true
                tryAgain.state = .on
                cancel.state = .on
            }
            .store(in: &subs)
        
        Task {
            try? await Task.sleep(nanoseconds: 450_000_000)            
            await share()
        }
    }
    
    override var allowsVibrancy: Bool {
        true
    }
    
    @MainActor private func share() async {
        if let schema = await cloud.model.projects.first(where: { $0.id == syncher.header.id })?.schema {
            do {
                try await syncher.upload(schema: schema)
            } catch {
                self.error.send(error.localizedDescription)
                return
            }
        }
        
        do {
            let raw = try syncher.share()
            
            let watermark = NSImage(named: "Watermark")!
            let code = NSImage(cgImage: raw, size: .init(width: raw.width, height: raw.height))
            
            let image = NSImage(size: .init(width: raw.width, height: raw.height))
            image.lockFocus()
            
            code.draw(in: .init(origin: .zero, size: code.size))
            watermark.draw(in: .init(origin: .init(x: (raw.width - syncher.size) / 2,
                                                   y: (raw.height - syncher.size) / 2),
                                     size: .init(width: syncher.size,
                                                 height: syncher.size)))
            
            image.unlockFocus()
             
            let data = NSBitmapImageRep(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
                 .representation(using: .png, properties: [:])!
             
            let result = NSImage(data: data)!
            
            session.flow.value = .shared(syncher.header, result)
        } catch {
            self.error.send(error.localizedDescription)
        }
    }
}
