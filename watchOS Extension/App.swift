import SwiftUI
import Offline

@main struct App: SwiftUI.App {
    @State private var loading = true
    @State private var projects = [Project]()
    @Environment(\.scenePhase) private var phase
    @WKExtensionDelegateAdaptor(Delegate.self) private var delegate
    
    var body: some Scene {
        WindowGroup {
            Main(projects: projects, loading: loading)
                .task {
                    cloud.ready.notify(queue: .main) {
                        cloud.pull.send()
                        loading = false
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
