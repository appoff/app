import SwiftUI
import CoreLocation

struct Preferences: View {
    let session: Session
    @State private var notifications = false
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
                        withAnimation(.easeInOut(duration: 0.4)) {
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
            
            let settings = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
            notifications = settings != .notDetermined && settings != .denied
        }
    }
    
    private var purchases: some View {
        Section("In-App Purchases") {
            NavigationLink(destination: Info(title: "Privacy Policy", text: Copy.policy)) {
                Label("Offline Cloud", systemImage: "cloud")
                    .symbolRenderingMode(.hierarchical)
                    .font(.callout)
                    .foregroundColor(.primary)
            }
        }
        .headerProminence(.increased)
    }
    
    private var privacy: some View {
        Section("Privacy") {
            Button {
                UIApplication.shared.settings()
            } label: {
                HStack {
                    Text("Notifications")
                        .font(.callout)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: notifications
                          ? "checkmark.circle.fill"
                          : "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.primary)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 22)
                    Image(systemName: "app.badge")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .light))
                        .frame(width: 24)
                }
            }
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
                        .frame(width: 24)
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
                        .frame(width: 24)
                }
            }
        }
        .headerProminence(.increased)
    }
    
    private var app: some View {
        Section("Offline") {
            NavigationLink(destination: About.init) {
                HStack {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26)
                    Text("About")
                        .font(.callout)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
            
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
                        .frame(width: 24)
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
                        .frame(width: 24)
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
