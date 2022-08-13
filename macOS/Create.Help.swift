import AppKit
import Coffee
import Combine

extension Create {
    final class Help: NSView {
        private var subs = Set<AnyCancellable>()
        
        required init?(coder: NSCoder) { nil }
        init() {
            super.init(frame: .init(x: 0, y: 0, width: 520, height: 440))
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
            
            [titleBasic, titleMarkers, titleControls]
                .forEach {
                    $0.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .title1).pointSize + 2, weight: .semibold)
                    $0.textColor = .labelColor
                }
            
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
                titleControls])
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
//                    if stack.visibilityPriority(for: basic) == .notVisible {
//                        collapseControls.symbol = "chevron.down"
//                        stack.animator().setVisibilityPriority(.mustHold, for: basic)
//                    } else {
//                        collapseControls.symbol = "chevron.right"
//                        stack.animator().setVisibilityPriority(.notVisible, for: controls)
//                    }
                }
                .store(in: &subs)
            
            [collapseBasic, collapseMarkers, collapseControls]
                .forEach {
                    scroll.documentView!.addSubview($0)
                    $0.rightAnchor.constraint(equalTo: scroll.documentView!.rightAnchor, constant: -50).isActive = true
                }
            
            stack.setCustomSpacing(5, after: titleBasic)
            stack.setCustomSpacing(5, after: titleMarkers)
            stack.setCustomSpacing(5, after: titleControls)
            
            scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
            scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            collapseBasic.centerYAnchor.constraint(equalTo: titleBasic.centerYAnchor).isActive = true
            collapseMarkers.centerYAnchor.constraint(equalTo: titleMarkers.centerYAnchor).isActive = true
            collapseControls.centerYAnchor.constraint(equalTo: titleControls.centerYAnchor).isActive = true
            
            scroll.documentView!.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 40).isActive = true
            
            stack.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor, constant: 50).isActive = true
            stack.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor, constant: 50).isActive = true
            stack.rightAnchor.constraint(equalTo: scroll.documentView!.rightAnchor, constant: -40).isActive = true
        }
    }
}
