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
                case .uploaded:
                    Text("Uploaded")
                case let .error(error):
                    Text("Error \(error.localizedDescription)")
                }
                
                Spacer()
            }
            .task {
                guard let schema = await cloud.model.projects.first { $0.id == offloader.header.id }?.schema else {
                    status = .error(Offloader.Error.offloaded)
                    return
                }
                
                do {
                    try await offloader.save(schema: schema)
                    status = .uploaded
                } catch {
                    status = .error(error)
                }
            }
        }
    }
}
