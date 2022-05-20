import SwiftUI
import Offline

struct Main: View {
    @ObservedObject var session: Session
    @State private var search = ""
    @State private var maps = [Offline.Item]()
    
    var body: some View {
        ZStack {
            List {
                if maps.isEmpty {
                    VStack {
                        Image(systemName: "map")
                            .font(.system(size: 30, weight: .ultraLight))
                            .foregroundStyle(.secondary)
                            .padding(.top, 100)
                        Text("No maps found")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 5)
                    }
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .greatestFiniteMagnitude)
                } else {
                    ForEach(filtered) {
                        Item(session: session,
                             item: $0)
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $search)
            
            if let selected = session.selected {
                Detail(session: session,
                       item: selected.item,
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
                        .font(.system(size: 16, weight: .regular))
                        .frame(minWidth: 40, minHeight: 30)
                        .contentShape(Rectangle())
                }
                
                Button {
                    session.flow = .create
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .regular))
                        .frame(minWidth: 40, minHeight: 30)
                        .contentShape(Rectangle())
                }
            }
        }
        .onReceive(cloud) {
            maps = $0.maps
        }
    }
    
    private var filtered: [Offline.Item] {
        { string in
            string.isEmpty
            ? maps
            : { components in
                maps
                    .filter {
                        $0.contains(tokens: components)
                    }
            } (string.components(separatedBy: " "))
        } (search.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
