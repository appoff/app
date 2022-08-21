import SwiftUI
import CoreLocation

struct Preferences: View {
    let session: Session
    @State private var store = false
    @State private var about = false
    @State private var location = false
    
    var body: some View {
        NavigationView {
            List {
                purchases
                privacy
                app
                help
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.easeIn(duration: 0.4)) {
                            session.flow = .main
                        }
                    } label: {
                        Text("Done")
                            .font(.callout.weight(.medium))
                            .padding(.vertical)
                            .padding(.horizontal, 4)
                            .contentShape(Rectangle())
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .task {
            let status = CLLocationManager().authorizationStatus
            location = status != .denied || status != .notDetermined
        }
    }
    
    private var purchases: some View {
        Section("In-App Purchases") {
            Button {
                store = true
            } label: {
                HStack {
                    Text("Offline Cloud")
                        .font(.callout)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "cloud")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .light))
                        .frame(width: 18)
                }
            }
            .sheet(isPresented: $store, content: Purchases.init)
        }
        .headerProminence(.increased)
    }
    
    private var privacy: some View {
        Section("Privacy") {
            Button {
                UIApplication.shared.settings()
            } label: {
                HStack {
                    Text("Location")
                        .font(.callout)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: location
                          ? "checkmark.circle.fill"
                          : "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.primary)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 22)
                    Image(systemName: "location")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .light))
                        .frame(width: 18)
                }
            }
            Button {
                UIApplication.shared.settings()
            } label: {
                HStack {
                    Text("Photos and camera")
                        .font(.callout)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "qrcode.viewfinder")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .light))
                        .frame(width: 18)
                }
            }
        }
        .headerProminence(.increased)
    }
    
    private var app: some View {
        Section("Offline") {
            Button {
                about = true
            } label: {
                HStack {
                    Text("About")
                        .font(.callout)
                        .foregroundColor(.primary)
                    Spacer()
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26)
                }
            }
            .sheet(isPresented: $about, content: About.init)
            
            Button {
                Task {
                    await UIApplication.shared.review()
                }
            } label: {
                HStack {
                    Text("Rate on the App Store")
                        .font(.callout)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "star")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .light))
                        .frame(width: 18)
                }
            }
            
            Link(destination: .init(string: "https://appoff.github.io/about")!) {
                HStack {
                    Text("appoff.github.io/about")
                        .foregroundColor(.primary)
                        .font(.callout)
                    
                    Spacer()
                    Image(systemName: "link")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .light))
                        .frame(width: 18)
                }
            }
        }
        .headerProminence(.increased)
    }
    
    private var help: some View {
        Section("Help") {
            NavigationLink(destination: Info(title: "Privacy Policy", text: Copy.policy)) {
                Label("Privacy Policy", systemImage: "hand.raised")
                    .symbolRenderingMode(.hierarchical)
                    .font(.callout)
                    .foregroundColor(.primary)
            }
            
            NavigationLink(destination: Info(title: "Terms and Conditions", text: Copy.terms)) {
                Label("Terms and Conditions", systemImage: "doc.plaintext")
                    .symbolRenderingMode(.hierarchical)
                    .font(.callout)
                    .foregroundColor(.primary)
            }
        }
        .headerProminence(.increased)
    }
}
