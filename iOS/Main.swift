import SwiftUI
import Offline

struct Main: View {
    @ObservedObject var session: Session
    @State private var search = ""
    @State private var maps = [Offline.Map]()
    @State private var thumbnails = [UUID : Data]()
    
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
                             map: $0,
                             thumbnail: thumbnail(map: $0))
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $search)
            
            if let selected = session.selected {
                Detail(session: session,
                       map: selected.map,
                       namespace: selected.namespace,
                       thumbnail: thumbnail(map: selected.map))
                    .transition(.identity)
            }
        }
        .navigationTitle("Maps")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarHidden(session.selected != nil)
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
            thumbnails = $0.thumbnails
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
    
    private func thumbnail(map: Offline.Map) -> UIImage? {
        thumbnails[map.id]
            .flatMap(UIImage.init(data:))
    }
}
