import AppKit
import Coffee
import Combine
import Offline

extension Sidebar {
    final class Item: Control {
        private weak var background: Vibrant!
        private var subs = Set<AnyCancellable>()
        
        required init?(coder: NSCoder) { nil }
        init(session: Session, item: Project) {
            let background = Vibrant(layer: true)
            self.background = background
            
            super.init(layer: false)
            background.layer!.cornerRadius = 20
            addSubview(background)
            
            let image: NSView
            
            if let thumbnail = item.schema.flatMap({ NSImage(data: $0.thumbnail) }) {
                image = .init()
                image.layer = .init()
                image.layer!.contentsGravity = .resizeAspectFill
                image.layer!.contents = thumbnail
                image.layer!.cornerRadius = background.layer!.cornerRadius
                image.layer!.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
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
            
            widthAnchor.constraint(equalToConstant: 218).isActive = true
            heightAnchor.constraint(equalToConstant: 160).isActive = true
            
            background.topAnchor.constraint(equalTo: topAnchor).isActive = true
            background.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            background.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            background.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
            
            image.topAnchor.constraint(equalTo: background.topAnchor).isActive = true
            image.heightAnchor.constraint(equalToConstant: 80).isActive = true
            image.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            image.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
            
            click
                .sink {
                    session.flow.value = .selected(item)
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
                        background.layer!.backgroundColor = NSColor.labelColor.withAlphaComponent(0.1).cgColor
                    default:
                        background.layer!.backgroundColor = .clear
                    }
                }
        }
    }
}


/*
 
 import SwiftUI
 import Offline

 extension Main {
     struct Item: View {
         let session: Session
         let project: Project
         @Namespace private var namespace
         
         var body: some View {
             Button {
                 withAnimation(.easeOut(duration: 0.4)) {
                     session.selected = (project: project, namespace: namespace)
                 }
             } label: {
                 ZStack {
                     Rectangle()
                         .fill(Color(.tertiarySystemBackground))
                         .matchedGeometryEffect(id: "background", in: namespace)
                     VStack(spacing: 0) {
                         if let thumbnail = project.schema.flatMap { UIImage(data: $0.thumbnail) } {
                             Image(uiImage: thumbnail)
                                 .resizable()
                                 .matchedGeometryEffect(id: "image", in: namespace)
                                 .scaledToFill()
                                 .aspectRatio(contentMode: .fill)
                                 .clipped()
                         } else {
                             Image(systemName: "cloud")
                                 .font(.system(size: 60, weight: .ultraLight))
                                 .matchedGeometryEffect(id: "image", in: namespace)
                                 .symbolRenderingMode(.hierarchical)
                                 .foregroundStyle(.secondary)
                                 .padding(.top, 30)
                                 .padding(.bottom)
                         }
                         Info(header: project.header, size: 0)
                             .matchedGeometryEffect(id: "info", in: namespace)
                             .lineLimit(1)
                             .padding(.bottom, 20)
                     }
                 }
                 .matchedGeometryEffect(id: "card", in: namespace)
                 .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                 .shadow(color: .init(white: 0, opacity: 0.1), radius: 8, y: 6)
             }
             .buttonStyle(.plain)
             .padding(.bottom, 10)
         }
     }
 }

 
 */
