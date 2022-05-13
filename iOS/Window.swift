import SwiftUI

struct Window: View {
    @StateObject private var session = Session()
    
    var body: some View {
        switch session.flow {
        case .main:
            NavigationView {
                Main(session: session)
                    .ignoresSafeArea(.keyboard)
            }
            .navigationViewStyle(.stack)            
        case .create:
            Create(session: session)
        case let .loading(factory):
            Loading(session: session, factory: factory)
                .transition(.move(edge: .bottom))
        }
    }
}