import SwiftUI

@main struct App: SwiftUI.App {
    @State private var selection = 0
    @Environment(\.scenePhase) private var phase
    @WKExtensionDelegateAdaptor(Delegate.self) private var delegate
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selection) {
                Circle()
            }
            .task {
                cloud.ready.notify(queue: .main) {
                    cloud.pull.send()
                }
            }
        }
        .onChange(of: phase) {
            if $0 == .active {
                cloud.pull.send()
            }
        }
    }
}
