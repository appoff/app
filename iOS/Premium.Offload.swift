import SwiftUI
import Offline

extension Premium {
    struct Offload: View {
        let header: Header
        @State private var status = Status.loading
        private let offloader = Offloader()
        
        var body: some View {
            VStack {
                switch status {
                case .loading:
                    Text("Loading")
                case .notfound:
                    Text("Not found")
                case let .error(error):
                    Text("Error \(error.localizedDescription)")
                }
                
                Spacer()
            }
            .task {
                do {
                    if try await offloader.exists(header: header) {
                        
                    } else {
                        status = .notfound
                    }
                } catch {
                    status = .error(error)
                }
            }
        }
    }
}
