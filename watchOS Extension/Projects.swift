import SwiftUI
import Offline

struct Projects: View {
    let projects: [Project]
    
    var body: some View {
        NavigationView {
            List(projects) { project in
                NavigationLink(destination: Detail(project: project)) {
                    Text(project.header.title)
                        .font(.callout)
                        .lineLimit(1)
                }
            }
            .navigationTitle("Maps")
        }
    }
}
