import AppKit
import Coffee
import Combine
import Offline

final class Share: NSView {
    private var subs = Set<AnyCancellable>()
    private let syncher: Syncher
    private let error = PassthroughSubject<String, Never>()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, header: Header) {
        self.syncher = .init(header: header)
        
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
            .sink {
                title.isHidden = false
                warning.isHidden = true
                fail.stringValue = ""
                fail.isHidden = true
                please.isHidden = false
                tryAgain.state = .hidden
                cancel.state = .hidden
            }
            .store(in: &subs)
        
        [image, title, subtitle, warning, fail, please, tryAgain, cancel]
            .forEach {
                addSubview($0)
                
                $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            }
        
        image.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
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
        
        error.send("completion: hello world")
        
        Task {
            try? await Task.sleep(nanoseconds: 450_000_000)
            session.selected.value = nil
            
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
//            let raw = try syncher.share()
//
//            let watermark = UIImage(named: "Watermark")!.cgImage!
//            
//            UIGraphicsBeginImageContext(.init(width: raw.width, height: raw.height))
//            UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: .init(raw.height))
//            UIGraphicsGetCurrentContext()!.scaleBy(x: 1, y: -1)
//            UIGraphicsGetCurrentContext()!.draw(raw,
//                                                in: .init(origin: .zero,
//                                                          size: .init(width: raw.width,
//                                                                      height: raw.height)))
//            UIGraphicsGetCurrentContext()!.draw(watermark,
//                                                in: .init(origin: .init(x: (raw.width - size) / 2,
//                                                                        y: (raw.height - size) / 2),
//                                                          size: .init(width: size, height: size)))
//            let image = UIImage(cgImage: UIGraphicsGetCurrentContext()!.makeImage()!)
//            
//            UIGraphicsEndImageContext()
//            
//            UIApplication.shared.isIdleTimerDisabled = false
//            withAnimation(.easeOut(duration: 0.4)) {
//                session.flow = .shared(syncher.header, image)
//            }
        } catch {
            self.error.send(error.localizedDescription)
        }
    }
}
/*
struct Share: View {
    let session: Session
    let syncher: Syncher
    @State private var error: Error?
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 60, weight: .ultraLight))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)
            
            if error == nil {
                Text("Sharing")
                    .font(.title2.weight(.regular))
                    .padding(.top)
            }
            
            Text(syncher.header.title)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: 280)
            
            if let error = error {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50, weight: .ultraLight))
                    .symbolRenderingMode(.hierarchical)
                    .padding(.vertical)
                Text(error.localizedDescription)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 280)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Please wait")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if error != nil {
                Button {
                    error = nil
                    
                    Task {
                        await share()
                    }
                } label: {
                    Text("Try again")
                        .font(.body.weight(.bold))
                        .foregroundColor(.primary)
                        .padding()
                        .contentShape(Rectangle())
                }
                .padding(.bottom)
                
                Button(role: .destructive) {
                    UIApplication.shared.isIdleTimerDisabled = false
                    
                    withAnimation(.easeIn(duration: 0.4)) {
                        session.flow = .main
                    }
                } label: {
                    Text("Cancel")
                        .font(.callout.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding()
                        .contentShape(Rectangle())
                }
                .padding(.bottom, 30)
            }
        }
        .task {
            UIApplication.shared.isIdleTimerDisabled = true
            
            try? await Task.sleep(nanoseconds: 450_000_000)
            session.selected = nil
            
            await share()
        }
    }
    
    
}
*/
