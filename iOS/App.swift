import SwiftUI
import Offline

@main struct App: SwiftUI.App {
    @State private var purchased = false
    @Environment(\.scenePhase) private var phase
    @UIApplicationDelegateAdaptor(Delegate.self) private var delegate
    
    var body: some Scene {
        WindowGroup {
            Window()
                .sheet(isPresented: $purchased) {
                    Sheet(rootView: Purchased())
                }
                .onReceive(store.purchased) {
                    purchased = true
                }
                .task {
                    cloud.ready.notify(queue: .main) {
                        Defaults.start()
                    }
                    
                    Task
                        .detached {
                            await store.launch()
                        }
                }
        }
        .onChange(of: phase) {
            switch $0 {
            case .active:
                cloud.pull.send()
            default:
                break
            }
        }
    }
}
