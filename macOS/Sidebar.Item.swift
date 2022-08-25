import AppKit
import Coffee
import Combine
import Offline

extension Sidebar {
    final class Item: Control {
        let id: UUID
        private weak var background: Vibrant!
        private var subs = Set<AnyCancellable>()
        
        required init?(coder: NSCoder) { nil }
        init(session: Session, item: Project) {
            id = item.id
            let background = Vibrant(layer: true)
            self.background = background
            
            super.init(layer: false)
            addSubview(background)
            
            let image: NSView
            
            if let thumbnail = item.schema.flatMap({ NSImage(data: $0.thumbnail) }) {
                image = .init()
                image.layer = .init()
                image.layer!.contentsGravity = .resizeAspectFill
                image.layer!.contents = thumbnail
                image.wantsLayer = true
                addSubview(image)
            } else {
                image = NSImageView(image: NSImage(systemSymbolName: "cloud", accessibilityDescription: nil) ?? .init())
                (image as! NSImageView).symbolConfiguration = .init(pointSize: 40, weight: .ultraLight)
                    .applying(.init(hierarchicalColor: .tertiaryLabelColor))
                (image as! NSImageView).imageScaling = .scaleNone
                background.addSubview(image)
            }
            
            image.translatesAutoresizingMaskIntoConstraints = false

            let info = Info(session: session, header: item.header, full: false)
            background.addSubview(info)
            
            let divider = Separator()
            background.addSubview(divider)
            
            widthAnchor.constraint(equalToConstant: 267).isActive = true
            bottomAnchor.constraint(equalTo: divider.bottomAnchor).isActive = true
            
            background.topAnchor.constraint(equalTo: topAnchor).isActive = true
            background.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            background.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            background.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            image.topAnchor.constraint(equalTo: background.topAnchor, constant: 1).isActive = true
            image.heightAnchor.constraint(equalToConstant: 269).isActive = true
            image.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
            image.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
            
            info.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
            info.leftAnchor.constraint(equalTo: background.leftAnchor, constant: 10).isActive = true
            info.rightAnchor.constraint(equalTo: background.rightAnchor, constant: -12).isActive = true
            
            divider.topAnchor.constraint(equalTo: info.bottomAnchor, constant: 15).isActive = true
            divider.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            divider.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
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
                    case .highlighted, .pressed, .selected:
                        background.layer!.backgroundColor = NSColor.labelColor.withAlphaComponent(0.15).cgColor
                    default:
                        background.layer!.backgroundColor = .clear
                    }
                }
        }
    }
}
