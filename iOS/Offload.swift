import SwiftUI
import Offline

struct Offload: View {
    let session: Session
    let syncher: Syncher
    @State private var error: Error?
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "icloud.and.arrow.up")
                .font(.system(size: 60, weight: .ultraLight))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)
            
            if error == nil {
                Text("Offloading")
                    .font(.title2.weight(.regular))
                    .padding(.top)
            }
            
            Text(syncher.header.title)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: 280)
            
            if let error = error {
                Text(error.localizedDescription)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 280)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 20)
            }
            
            Spacer()
            
            if error != nil {
                Button {
                    error = nil
                    
                    Task {
                        await offload()
                    }
                } label: {
                    Text("Try again")
                        .font(.body.weight(.bold))
                        .foregroundColor(.primary)
                        .padding()
                        .contentShape(Rectangle())
                }
                .padding(.bottom)
                
                Button(role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        session.flow = .main
                    }
                } label: {
                    Text("Cancel")
                        .font(.callout.weight(.medium))
                        .foregroundColor(.primary)
                        .padding()
                        .contentShape(Rectangle())
                }
                .padding(.bottom, 30)
            }
        }
        
//        VStack {
//            switch status {
//            case .loading:
//                Text("Loading")
//            case .notfound:
//                Text("Not found")
//            case .cleaning:
//                Text("Cleaning")
//            case .finished:
//                Text("Finished")
//            case let .error(error):
//                Text("Error \(error.localizedDescription)")
//            }
//
//            Spacer()
//        }
        .task {
            try? await Task.sleep(nanoseconds: 450_000_000)
            session.selected = nil
            
            await offload()
        }
    }
    
    private func offload() async {
        guard let schema = await cloud.model.projects.first(where: { $0.id == syncher.header.id })?.schema else {
            error = Syncher.Error.offloaded
            return
        }
        
        do {
            try await syncher.upload(schema: schema)
            await cloud.offload(header: syncher.header)
            
            withAnimation(.easeInOut(duration: 0.4)) {
                session.flow = .offloaded(syncher.header)
            }
        } catch {
            self.error = error
        }
    }
}
