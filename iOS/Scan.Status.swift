import SwiftUI
import Offline

extension Scan {
    final class Status: ObservableObject {
        @Published var video = true
        @Published var found: Any?
        @Published var error: Swift.Error?
        @Published var title: String?
        @Published var pick = false
        @Published var help = false
        let session: Session
        let picker = Picker()
        let camera = Camera()
        
        init(session: Session) {
            self.session = session
            picker.status = self
            camera.status = self
        }
        
        func load(header: Header) async throws {
            title = header.title
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            
            if await cloud.model.projects.contains(where: { $0.header.id == header.id }) {
                error = Error.existing
            } else {
                await cloud.add(header: header, schema: nil)
                
                if camera.session.isRunning {
                    camera.session.stopRunning()
                }
                
                withAnimation(.easeInOut(duration: 0.4)) {
                    session.flow = .download(header)
                }
            }
        }
        
        func clear() {
            error = nil
            title = nil
            found = nil
            pick = false
            help = false
        }
    }
}
