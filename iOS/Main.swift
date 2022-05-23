import SwiftUI
import Offline

struct Main: View {
    @ObservedObject var session: Session
    @State private var search = ""
    @State private var projects = [Project]()
    
    var body: some View {
        ZStack {
            List {
                if projects.isEmpty {
                    VStack {
                        Image(systemName: "map")
                            .font(.system(size: 35, weight: .ultraLight))
                            .foregroundStyle(.secondary)
                            .padding(.top, 100)
                        Text("Empty maps")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(.top, 5)
                    }
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .greatestFiniteMagnitude)
                } else {
                    ForEach(filtered) {
                        Item(session: session,
                             project: $0)
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $search)
            
            if let selected = session.selected {
                Detail(session: session,
                       project: selected.project,
                       namespace: selected.namespace)
                    .transition(.identity)
            }
        }
        .navigationTitle("Maps")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarHidden(session.selected != nil)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if !filtered.isEmpty {
                    Text(filtered.count.formatted() + (filtered.count == 1 ? " map" : " maps"))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .fixedSize()
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 18, weight: .regular))
                        .frame(minWidth: 40, minHeight: 30)
                        .contentShape(Rectangle())
                }
                
                Button {
                    session.flow = .create
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .regular))
                        .frame(minWidth: 40, minHeight: 30)
                        .contentShape(Rectangle())
                }
            }
        }
        .onReceive(cloud) {
            projects = $0.projects
        }
    }
    
    private var filtered: [Project] {
        { string in
            string.isEmpty
            ? projects
            : { components in
                projects
                    .filter {
                        $0.contains(tokens: components)
                    }
            } (string.components(separatedBy: " "))
        } (search.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
