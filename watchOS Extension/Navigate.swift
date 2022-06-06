import SwiftUI
import Offline

struct Navigate: View {
    let schema: Schema
    
    var body: some View {
        ZStack {
            Draw()
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}
