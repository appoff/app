import SwiftUI
import Offline

struct Projects: View {
    let projects: [Project]
    
    var body: some View {
        NavigationView {
            List(projects) { project in
                NavigationLink(destination: Item(project: project)) {
                    Text(project.header.title)
                }
            }
            .navigationTitle("Maps")
        }
    }
}
