import SwiftUI

extension Create {
    struct Help: View {
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationView {
                List {
                    Section("Basic") {
                        Text(.init(Copy.basic)).font(.callout)
                    }
                    
                    Section("Markers") {
                        Text(.init(Copy.markers)).font(.callout)
                    }

                    Section("Controls") {
                        Helper(symbol: "character.cursor.ibeam", size: 20, title: "Differentiate your map with a title.")
                        Helper(symbol: "slider.horizontal.3", size: 22, title: "Options menu.")
                        Helper(symbol: "magnifyingglass", size: 20, title: "Search for an address or place of interest.")
                        Helper(symbol: "square.stack.3d.up", size: 22, title: "Settings menu.")
                        Helper(symbol: "location.viewfinder", size: 22, title: "Follow your current location.")
                    }
                }
                .listStyle(.sidebar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .font(.callout)
                                .padding(.vertical)
                                .padding(.horizontal, 4)
                                .contentShape(Rectangle())
                        }
                    }
                }
                .navigationTitle("Creating a map")
                .navigationBarTitleDisplayMode(.large)
            }
            .navigationViewStyle(.stack)
        }
    }
}
