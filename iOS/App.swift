import SwiftUI

@main struct App: SwiftUI.App {
    @StateObject private var session = Session()
    
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
    }
}


struct Item {
    
}
