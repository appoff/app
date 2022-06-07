import SwiftUI
import Offline

struct Navigate: View {
    let schema: Schema
    @StateObject private var session = Session()
    
    var body: some View {
        ZStack {
            Draw(session: session)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}
