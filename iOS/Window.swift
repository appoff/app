import SwiftUI

struct Window: View {
    @StateObject private var session = Session()
    
    var body: some View {
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
