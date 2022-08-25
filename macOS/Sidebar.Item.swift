import AppKit
import Coffee
import Combine
import Offline

extension Sidebar {
    final class Item: Control {
        let id: UUID
        private weak var image: NSView!
        private weak var blur: NSVisualEffectView!
        private var subs = Set<AnyCancellable>()
        
        required init?(coder: NSCoder) { nil }
        init(session: Session, item: Project) {
            id = item.id
            
            let image = NSView()
            image.layer = .init()
            image.layer!.contents = item.schema.flatMap { NSImage(data: $0.thumbnail) }
            image.layer!.contentsGravity = .resizeAspectFill
            image.layer!.borderWidth = 6
            image.wantsLayer = true
            image.translatesAutoresizingMaskIntoConstraints = false
            self.image = image
            
            let blur = NSVisualEffectView()
            blur.state = .active
            blur.blendingMode = .withinWindow
            blur.translatesAutoresizingMaskIntoConstraints = false
            self.blur = blur
            
            super.init(layer: false)
            addSubview(image)
            addSubview(blur)
            
            let info = Info(session: session, header: item.header, full: false)
            blur.addSubview(info)
            
            widthAnchor.constraint(equalToConstant: 269).isActive = true
            heightAnchor.constraint(equalTo: widthAnchor).isActive = true
            
            image.topAnchor.constraint(equalTo: topAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            image.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            blur.topAnchor.constraint(equalTo: info.topAnchor, constant: -20).isActive = true
            blur.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            blur.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            blur.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            info.bottomAnchor.constraint(equalTo: blur.bottomAnchor, constant: -20).isActive = true
            info.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            info.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            
            click
                .sink {
                    session.selected.value = item
                    session.flow.value = .main
                }
                .store(in: &subs)
        }
        
        override func updateLayer() {
            super.updateLayer()
            
            NSApp
                .effectiveAppearance
                .performAsCurrentDrawingAppearance {
                    switch state {
                    case .selected:
                        blur.isHidden = true
                        image.layer!.borderColor = NSColor.labelColor.withAlphaComponent(0.5).cgColor
                    case .highlighted, .pressed:
                        image.layer!.borderColor = NSColor.labelColor.withAlphaComponent(0.5).cgColor
                        blur.material = .sheet
                        blur.isHidden = false
                    default:
                        image.layer!.borderColor = .clear
                        blur.material = .hudWindow
                        blur.isHidden = false
                    }
                }
        }
    }
}
