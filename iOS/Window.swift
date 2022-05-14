import SwiftUI

struct Window: View {
    @StateObject private var session = Session()
    @Namespace private var animation
    
    var body: some View {
        switch session.flow {
        case .main:
            NavigationView {
                Main(session: session, animation: animation)
                    .ignoresSafeArea(.keyboard)
            }
            .navigationViewStyle(.stack)
        case .create:
            Create(session: session)
        case let .detail(map, thumbnail):
            Detail(session: session, map: map, thumbnail: thumbnail, animation: animation)
                .transition(.identity)
        case let .loading(factory):
            Loading(session: session, factory: factory)
                .transition(.move(edge: .bottom))
        }
    }
}
