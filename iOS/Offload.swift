import SwiftUI
import Offline

struct Offload: View {
    let session: Session
    let syncher: Syncher
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
            guard let schema = await cloud.model.projects.first(where: { $0.id == syncher.header.id })?.schema else {
                status = .error(Syncher.Error.offloaded)
                return
            }
            
            do {
                try await syncher.upload(schema: schema)
                status = .cleaning
                
                await cloud.offload(header: syncher.header)
                syncher.delete()
                status = .finished
            } catch {
                status = .error(error)
            }
        }
    }
}
