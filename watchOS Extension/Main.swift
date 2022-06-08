import SwiftUI
import Offline

struct Main: View {
    let projects: [Project]
    let loading: Bool
    
    var body: some View {
        NavigationView {
            List {
//                NavigationLink(destination: Compass()) {
//                    HStack {
//                        Text("Compass")
//                            .font(.callout)
//                        Spacer()
//                        Image(systemName: "location.north.fill")
//                            .font(.system(size: 12, weight: .medium))
//                    }
//                    .padding(.vertical, 14)
//                    .contentShape(Rectangle())
//                }
                
                if loading {
                    Text("\nLoading maps...")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.clear)
                } else if projects.isEmpty {
                    Text("\nEmpty maps")
                        .listRowBackground(Color.clear)
                    Text("""
        Once you create maps they appear here.

        Create them on Offline for iPhone, iPad and Mac.
        """)
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                        .listRowBackground(Color.clear)
                } else {
                    Text("\nMaps")
                        .font(.callout)
                        .listRowBackground(Color.clear)
                    
                    ForEach(projects) { project in
                        NavigationLink(destination: Detail(project: project)) {
                            Text(project.header.title)
                                .font(.callout)
                                .lineLimit(1)
                                .padding(.vertical, 14)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
        }
    }
}
