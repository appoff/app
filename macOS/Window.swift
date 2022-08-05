import AppKit
import Combine

final class Window: NSWindow {
    private var subs = Set<AnyCancellable>()
    private let session: Session
    
    init(session: Session) {
        self.session = session
        super.init(contentRect: .init(x: 0,
                                      y: 0,
                                      width: 980,
                                      height: 600),
                   styleMask: [.closable, .miniaturizable, .resizable, .titled, .fullSizeContentView],
                   backing: .buffered,
                   defer: false)
        minSize.height = 200
        center()
        toolbar = .init()
        isReleasedWhenClosed = false
        collectionBehavior = .fullScreenNone
        setFrameAutosaveName("Window")
        tabbingMode = .disallowed
        titlebarAppearsTransparent = true

        let bar = NSTitlebarAccessoryViewController()
        bar.view = Topbar(session: session)
        bar.layoutAttribute = .top
        addTitlebarAccessoryViewController(bar)
        
        let sidebar = Sidebar(session: session)
        contentView!.addSubview(sidebar)
        
        let content = Content(session: session)
        contentView!.addSubview(content)
        
        sidebar.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        sidebar.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        sidebar.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true

        content.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: sidebar.rightAnchor).isActive = true
        content.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
    }
    
    override func close() {
        super.close()
        NSApp.terminate(nil)
    }
}