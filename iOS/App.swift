import SwiftUI

@main struct App: SwiftUI.App {
    @State private var search = ""
    @State private var maps = [Map]()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ScrollView {
                    if maps.isEmpty {
                        Image(systemName: "map")
                            .font(.system(size: 30, weight: .ultraLight))
                            .foregroundStyle(.secondary)
                            .padding(.top, 100)
                        Text("No maps found")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 5)
                    } else {
                        VStack(spacing: 0) {
                            
                        }
                    }
                }
                .navigationTitle("Maps")
                .navigationBarTitleDisplayMode(.large)
                .searchable(text: $search)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 16, weight: .regular))
                                .frame(minWidth: 40, minHeight: 30)
                                .contentShape(Rectangle())
                        }
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .regular))
                                .frame(minWidth: 40, minHeight: 30)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
            .navigationViewStyle(.stack)
        }
    }
}


struct Map {
    
}
