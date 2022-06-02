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
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .headerProminence(.increased)
                    
                    Section("Markers") {
                        Text("""
You can add markers by touching down on the map and keeping it pressed for a few seconds (**Long press touch**).

It is also possible to add markers by searching for a specific address or point of interest, if you select any search result it will be added to the map.

Every time you add or remove a marker the directions between the markers will be updated.

Once a marker is added you can remove it by selecting it and hitting the remove button on the popup.
""").font(.callout)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .headerProminence(.increased)

                    Section("Controls") {
                        HStack(spacing: 0) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 34, weight: .thin))
                                .symbolRenderingMode(.hierarchical)
                                .frame(width: 64)
                            Text("""
    Use the camera on your device to scan a *QR Code* and start downloading the map.
    """).font(.callout)
                            Spacer()
                        }
                        HStack(spacing: 0) {
                            Image(systemName: "photo")
                                .font(.system(size: 28, weight: .thin))
                                .symbolRenderingMode(.hierarchical)
                                .frame(width: 64)
                            Text("""
    You can also import a *QR Code* by selecting an image from your *Photo Library*.
    """).font(.callout)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .headerProminence(.increased)
                    
                    Section("3. Downloading") {
                        Text("""
When a *QR Code* is loaded the map will start downloading.
""").font(.callout)
                        Text("""
Maps use a lot of memory, so if you are not using a stable connection, or you are using mobile data the map will not be downloaded at the moment.
""").font(.callout)
                        Text("""
If there is any error downloading the map, this will still be added to the list of your maps and you can try downloading it again when you get a more stable Internet connection.
""").font(.callout)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .headerProminence(.increased)
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
