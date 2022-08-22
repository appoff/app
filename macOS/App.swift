import AppKit
import Offline

@NSApplicationMain final class App: NSApplication, NSApplicationDelegate {
    private let session = Session()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        delegate = self
    }
    
//    func applicationWillFinishLaunching(_: Notification) {
//        mainMenu = Menu(session: session)
//    }
    
    func applicationDidFinishLaunching(_: Notification) {
        registerForRemoteNotifications()
        Window(session: session).makeKeyAndOrderFront(nil)
        
        cloud.ready.notify(queue: .main) {
            self.session.loading.value = false
//            Defaults.start()
            
//            Task
//                .detached {
//                    await self.session.store.launch()
//                }
        }
    }
    
    func applicationDidBecomeActive(_: Notification) {
        cloud.pull.send()
    }
    
    func application(_: NSApplication, didReceiveRemoteNotification: [String : Any]) {
        cloud.pull.send()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
    
    func anyWindow<T>() -> T? {
        windows
            .compactMap {
                $0 as? T
            }
            .first
    }
    
    override func orderFrontStandardAboutPanel(_ sender: Any?) {
//        (anyWindow() ?? About())
//            .makeKeyAndOrderFront(nil)
    }
    
    @objc func showPreferencesWindow(_ sender: Any?) {
//        (anyWindow() ?? Preferences(session: session))
//            .makeKeyAndOrderFront(nil)
    }
}
