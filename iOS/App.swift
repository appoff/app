import SwiftUI

@main struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Main()
            }
            .navigationViewStyle(.stack)
        }
    }
}


struct Item {
    
}
