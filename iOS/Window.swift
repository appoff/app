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
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
        case .create:
            Create(session: session)
        case let .created(map):
            Created(session: session, map: map)
                .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
        case let .deleted(map):
            Deleted(session: session, map: map)
                .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
        case let .loading(factory):
            Loading(session: session, factory: factory)
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
        case let .unzip(item):
            Unzip(session: session, item: item)
                .transition(.opacity)
        case let .navigate(signature, tiles):
            Navigate(session: session, control: .init(signature: signature, tiles: tiles))
        }
    }
}
