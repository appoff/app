import SwiftUI
import Offline

extension Premium {
    struct Offload: View {
        let offloader: Offloader
        @State private var status = Status.loading
        
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
                let schema = await cloud.model.projects.first { $0.id == offloader.header.id }?.schema
                
//                do {
//                    if try await offloader.save(schema: schema) {
//                        
//                    } else {
//                        status = .notfound
//                    }
//                } catch {
//                    status = .error(error)
//                }
            }
        }
    }
}
