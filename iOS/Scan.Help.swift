import SwiftUI

extension Scan {
    struct Help: View {
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationView {
                List {
                    Section("1. Sharing") {
                        Text("""
Users with **Offline Cloud** purchased can upload maps to the cloud and share them with a *QR Code*.
""").font(.callout)
                        Text("""
Once a map is uploaded with **Offline Cloud** a *QR Code* can be created at any time directly on the app.
""").font(.callout)
                        Text("""
Anyone can import a map from a QR Code, even if they have not purchased **Offline Cloud**.
""").font(.callout)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .headerProminence(.increased)
                    
                    Section("2. Importing") {
                        Helper(symbol: "qrcode.viewfinder",
                               size: 34,
                               title: "Use the camera on your device to scan a *QR Code* and start downloading the map.")
                        
                        Helper(symbol: "photo",
                               size: 28,
                               title: "You can also import a *QR Code* by selecting an image from your *Photo Library*.")
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
                .listStyle(.insetGrouped)
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
                .navigationTitle("Importing map")
                .navigationBarTitleDisplayMode(.large)
            }
            .navigationViewStyle(.stack)
        }
    }
}
