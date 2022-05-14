import SwiftUI
import Offline

struct Main: View {
    let session: Session
    @State private var search = ""
    @State private var maps = [Offline.Map]()
    
    var body: some View {
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
                    Item(session: session, map: $0)
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Maps")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $search)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if !filtered.isEmpty {
                    Text(filtered.count.formatted() + " maps")
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
    
    private var filtered: [Offline.Map] {
        { string in
            string.isEmpty
            ? maps
            : { components in
                maps
                    .filter { map in
                        components
                            .contains { token in
                                map.title.localizedCaseInsensitiveContains(token)
                                || map.origin.localizedCaseInsensitiveContains(token)
                                || map.destination.localizedCaseInsensitiveContains(token)
                            }
                    }
            } (string.components(separatedBy: " "))
        } (search.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
