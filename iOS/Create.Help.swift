import SwiftUI

extension Create {
    struct Help: View {
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationView {
                List {
                    Section("Basic") {
                        Text("""
You need at least **2 markers** to create a map. This way it is possible to know what area to save.

You can add more than 2 markers, as many as needed, but there is a limit on the maximum size of the map.

When a map is too big it can consume the whole memory of your device, and they took a very long time to create.

Make your maps as small as possible.

Once you set your desired markers on the map, you can hit **Save** and the map creation will begin, please be patient, this process can take a few minutes to complete.

Avoid creating maps under a cellular network, this will consume huge amounts of your mobile data.

Once you have created a map is not possible to edit it anymore, if you want to change anything you need to create a new one instead.
""").font(.callout)
                    }
                    
                    Section("Markers") {
                        Text("""
You can add markers by touching down on the map and keeping it pressed for a few seconds (**Long press touch**).

It is also possible to add markers by searching for a specific address or point of interest, if you select any search result it will be added to the map.

If you want to add a marker on your current location you can do that on the **Options** menu.

Every time you add or remove a marker the directions between the markers will be updated.

Once a marker is added you can remove it by selecting it and hitting the remove button on the popup.
""").font(.callout)
                    }

                    Section("Controls") {
                        Helper(symbol: "character.cursor.ibeam", size: 20, title: "Define a title to your map to differentiate it.")
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
                .navigationTitle("Creating map")
                .navigationBarTitleDisplayMode(.large)
            }
            .navigationViewStyle(.stack)
        }
    }
}
