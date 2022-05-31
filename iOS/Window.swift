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
        case let .created(header):
            Created(session: session, header: header)
                .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
        case let .deleted(header):
            Deleted(session: session, header: header)
                .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
        case let .loading(factory):
            Loading(session: session, factory: factory)
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
        case let .unzip(project):
            Unzip(session: session, project: project)
                .transition(.opacity)
        case let .offload(header):
            Offload(session: session, syncher: .init(header: header))
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
        case let .download(header):
            Download(session: session, syncher: .init(header: header))
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
        case let .downloaded(header):
            Downloaded(session: session, header: header)
                .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
        case let .offloaded(header):
            Offloaded(session: session, header: header)
                .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
        case let .share(header):
            Share(session: session, syncher: .init(header: header))
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
        case let .shared(header, image):
            Shared(session: session, header: header, image: image)
                .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
        case let .navigate(schema, bufferer):
            Navigate(session: session, control: .init(schema: schema, bufferer: bufferer))
        }
    }
}
