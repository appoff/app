import SwiftUI
import Offline

struct Main: View {
    let projects: [Project]
    let loading: Bool
    
    var body: some View {
        if loading {
            Loading()
        } else if projects.isEmpty {
            Empty()
        }
    }
}
