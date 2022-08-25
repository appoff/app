import AppKit
import Coffee
import Combine
import UniformTypeIdentifiers
import Offline

final class Shared: NSView {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, header: Header, image: NSImage) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let title = Text(vibrancy: true)
        title.stringValue = header.title
        title.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .title1).pointSize, weight: .medium)
        title.maximumNumberOfLines = 1
        title.lineBreakMode = .byTruncatingTail
        
        let imageView = NSImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.imageScaling = .scaleProportionallyDown
        
        let share = Control.Symbol(symbol: "square.and.arrow.up.circle", size: 35, content: 50, weight: .light)
        share.toolTip = "Share map"
        share
            .click
            .sink {
                let panel = NSSavePanel()
                panel.nameFieldStringValue = header.title
                panel.allowedContentTypes = [.png]
                panel.begin {
                    guard
                        $0 == .OK,
                        let url = panel.url,
                        let tiff = image.tiffRepresentation,
                        let data = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:])
                    else { return }
                    
                    try? data.write(to: url, options: .atomic)
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }
            }
            .store(in: &subs)
        
        let accept = Control.Plain(title: "Continue")
        accept.toolTip = "Continue"
        accept
            .click
            .sink {
                session.flow.value = .main
            }
            .store(in: &subs)
        
        [title, imageView, share, accept]
            .forEach {
                addSubview($0)
                
                $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            }
        
        title.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 45).isActive = true
        title.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        
        imageView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        share.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        
        accept.topAnchor.constraint(equalTo: share.bottomAnchor, constant: 20).isActive = true
        accept.widthAnchor.constraint(equalToConstant: 140).isActive = true
    }
}
