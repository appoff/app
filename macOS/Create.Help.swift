import AppKit
import Coffee
import Combine

extension Create {
    final class Help: NSView {
        private var subs = Set<AnyCancellable>()
        
        required init?(coder: NSCoder) { nil }
        init() {
            super.init(frame: .init(x: 0, y: 0, width: 540, height: 480))
            let scroll = Scroll()
            scroll.contentView.postsBoundsChangedNotifications = false
            scroll.contentView.postsFrameChangedNotifications = false
            addSubview(scroll)
            
            let stringBasic = (try? NSMutableAttributedString(markdown: Copy.basic, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
            ?? NSMutableAttributedString()
            
            let stringMarkers = (try? NSMutableAttributedString(markdown: Copy.markers, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
            ?? NSMutableAttributedString()
            
            [stringBasic, stringMarkers]
                .forEach {
                    $0.addAttributes([
                        .font: NSFont.systemFont(ofSize: NSFont.preferredFont(
                            forTextStyle: .title2).pointSize, weight: .regular),
                        .foregroundColor: NSColor.labelColor],
                                     range: .init(location: 0,
                                                  length: $0.length))
                }
            
            let title = Text(vibrancy: true)
            title.stringValue = "Creating a map"
            title.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .largeTitle).pointSize + 2, weight: .bold)
            title.textColor = .labelColor
            
            let titleBasic = Text(vibrancy: true)
            titleBasic.stringValue = "Basic"
            
            let basic = Text(vibrancy: true)
            basic.attributedStringValue = stringBasic
            
            let separatorBasic = Separator()
            
            let titleMarkers = Text(vibrancy: true)
            titleMarkers.stringValue = "Markers"
            
            let markers = Text(vibrancy: true)
            markers.attributedStringValue = stringMarkers
            
            let separatorMarkers = Separator()
            
            let titleControls = Text(vibrancy: true)
            titleControls.stringValue = "Controls"
            
            let controls = Stack(views: [
            control(symbol: "character.cursor.ibeam",
                    size: 20,
                    title: "Differentiate your map with a title."),
            control(symbol: "magnifyingglass",
                    size: 20,
                    title: "Search for an address or place of interest."),
            control(symbol: "slider.horizontal.3",
                    size: 22,
                    title: "Options menu."),
            control(symbol: "square.stack.3d.up",
                    size: 22,
                    title: "Settings menu."),
            control(symbol: "location.viewfinder",
                    size: 22,
                    title: "Follow your current location.")])
            controls.orientation = .vertical
            controls.alignment = .left
            controls.spacing = 0
            
            [title, titleBasic, titleMarkers, titleControls, basic, markers]
                .forEach {
                    $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                    $0.isSelectable = true
                    $0.allowsEditingTextAttributes = true
                }
            
            [separatorBasic, separatorMarkers]
                .forEach {
                    $0.heightAnchor.constraint(equalToConstant: 1).isActive = true
                }
            
            let stack = Stack(views: [
                title,
                titleBasic,
                basic,
                separatorBasic,
                titleMarkers,
                markers,
                separatorMarkers,
                titleControls,
                controls])
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.orientation = .vertical
            stack.alignment = .left
            stack.spacing = 30
            scroll.documentView!.addSubview(stack)
            
            let collapseBasic = Control.Symbol(symbol: "chevron.down",
                                               size: 12,
                                               content: 32,
                                               weight: .semibold)
            collapseBasic
                .click
                .sink {
                    if stack.visibilityPriority(for: basic) == .notVisible {
                        collapseBasic.symbol = "chevron.down"
                        stack.animator().setVisibilityPriority(.mustHold, for: basic)
                    } else {
                        collapseBasic.symbol = "chevron.right"
                        stack.animator().setVisibilityPriority(.notVisible, for: basic)
                    }
                }
                .store(in: &subs)
            
            let collapseMarkers = Control.Symbol(symbol: "chevron.down",
                                                 size: 12,
                                                 content: 32,
                                                 weight: .semibold)
            collapseMarkers
                .click
                .sink {
                    if stack.visibilityPriority(for: markers) == .notVisible {
                        collapseMarkers.symbol = "chevron.down"
                        stack.animator().setVisibilityPriority(.mustHold, for: markers)
                    } else {
                        collapseMarkers.symbol = "chevron.right"
                        stack.animator().setVisibilityPriority(.notVisible, for: markers)
                    }
                }
                .store(in: &subs)
            
            let collapseControls = Control.Symbol(symbol: "chevron.down",
                                                  size: 12,
                                                  content: 32,
                                                  weight: .semibold)
            collapseControls
                .click
                .sink {
                    if stack.visibilityPriority(for: controls) == .notVisible {
                        collapseControls.symbol = "chevron.down"
                        stack.animator().setVisibilityPriority(.mustHold, for: controls)
                    } else {
                        collapseControls.symbol = "chevron.right"
                        stack.animator().setVisibilityPriority(.notVisible, for: controls)
                    }
                }
                .store(in: &subs)
            
            [collapseBasic, collapseMarkers, collapseControls]
                .forEach {
                    scroll.documentView!.addSubview($0)
                    $0.rightAnchor.constraint(equalTo: scroll.documentView!.rightAnchor, constant: -30).isActive = true
                }
            
            [titleBasic, titleMarkers, titleControls]
                .forEach {
                    $0.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .title1).pointSize + 2, weight: .semibold)
                    $0.textColor = .labelColor
                    stack.setCustomSpacing(5, after: $0)
                }
            
            scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
            scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            collapseBasic.centerYAnchor.constraint(equalTo: titleBasic.centerYAnchor).isActive = true
            collapseMarkers.centerYAnchor.constraint(equalTo: titleMarkers.centerYAnchor).isActive = true
            collapseControls.centerYAnchor.constraint(equalTo: titleControls.centerYAnchor).isActive = true
            
            scroll.documentView!.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 60).isActive = true
            
            stack.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor, constant: 60).isActive = true
            stack.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor, constant: 60).isActive = true
            stack.rightAnchor.constraint(equalTo: scroll.documentView!.rightAnchor, constant: -60).isActive = true
        }
        
        func control(symbol: String, size: CGFloat, title: String) -> NSView {
            let image = NSImageView(image: .init(systemSymbolName: symbol, accessibilityDescription: nil) ?? .init())
            image.translatesAutoresizingMaskIntoConstraints = false
            image.imageScaling = .scaleNone
            image.symbolConfiguration = .init(pointSize: size, weight: .light)
                .applying(.init(hierarchicalColor: .labelColor))
            image.widthAnchor.constraint(equalToConstant: 48).isActive = true
            image.heightAnchor.constraint(equalToConstant: 46).isActive = true
            
            let text = Text(vibrancy: true)
            text.stringValue = title
            text.font = .systemFont(ofSize: NSFont.preferredFont(
                forTextStyle: .title2).pointSize, weight: .regular)
            text.textColor = .labelColor
            text.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            let stack = Stack(views: [image, text])
            stack.spacing = 0
            return stack
        }
    }
}
