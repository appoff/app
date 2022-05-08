import SwiftUI

@main struct App: SwiftUI.App {
    @StateObject private var session = Session()
    @Environment(\.scenePhase) private var phase
    @UIApplicationDelegateAdaptor(Delegate.self) private var delegate
    
    var body: some Scene {
        WindowGroup {
            switch session.flow {
            case .main:
                NavigationView {
                    Main(session: session)
                }
                .navigationViewStyle(.stack)
            case .create:
                Create(session: session)
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


struct Item {
    
}
