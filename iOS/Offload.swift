import SwiftUI
import Offline

struct Offload: View {
    let session: Session
    let offloader: Offloader
    @State private var status = Status.loading
    
    var body: some View {
        VStack {
            switch status {
            case .loading:
                Text("Loading")
            case .notfound:
                Text("Not found")
            case .cleaning:
                Text("Cleaning")
            case .finished:
                Text("Finished")
            case let .error(error):
                Text("Error \(error.localizedDescription)")
            }
            
            Spacer()
        }
        .task {
            guard let schema = await cloud.model.projects.first(where: { $0.id == offloader.header.id })?.schema else {
                status = .error(Offloader.Error.offloaded)
                return
            }
            
            do {
                try await offloader.save(schema: schema)
                status = .cleaning
                
                await cloud.offload(header: offloader.header)
                offloader.delete()
                status = .finished
            } catch {
                status = .error(error)
            }
        }
    }
}
