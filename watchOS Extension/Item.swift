import SwiftUI
import Offline

struct Item: View {
    let project: Project
    
    var body: some View {
        Text(project.header.title)
    }
}
