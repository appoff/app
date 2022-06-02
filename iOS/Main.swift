import SwiftUI
import Offline

struct Main: View {
    @ObservedObject var session: Session
    @State private var search = ""
    @State private var projects = [Project]()
    
    var body: some View {
        ZStack {
            List {
                if filtered.isEmpty {
                    VStack {
                        Image(systemName: "map")
                            .font(.system(size: 50, weight: .ultraLight))
                            .foregroundStyle(.secondary)
                            .padding(.top, 100)
                        Text(projects.isEmpty ? "Empty maps" : "No results")
                            .font(.body)
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
                        .font(.callout)
                        .fixedSize()
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if session.selected == nil {
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 30) {
                        Button {
                            
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 20, weight: .light))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.primary)
                                .frame(width: 60, height: 60)
                                .contentShape(Rectangle())
                        }
                        
                        Button {
                            session.flow = .create
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 42, weight: .thin))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.primary)
                                .frame(width: 60, height: 60)
                                .contentShape(Rectangle())
                        }
                        
                        Button {
                            session.flow = .scan
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 20, weight: .light))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.primary)
                                .frame(width: 60, height: 60)
                                .contentShape(Rectangle())
                        }
                    }
                    .frame(height: 62)
                }
                .background(.ultraThinMaterial)
            }
        }
        .onReceive(cloud) {
            projects = $0.projects
            
            print(projects.map(\.schema?.data))
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
