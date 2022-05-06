import SwiftUI
import MapKit

struct Create: View {
    let session: Session
    @State private var search = false
    @State private var cancel = false
    private let map = Map()
    
    var body: some View {
        map
            .edgesIgnoringSafeArea([.top, .leading, .trailing])
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    Divider()
                        .edgesIgnoringSafeArea(.horizontal)
                    
                    HStack {
                        Text("0 points")
                            .font(.callout)
                            .padding(.vertical)
                            .padding(.leading)
                        
                        Spacer()
                        
                        Button("Cancel", role: .destructive) {
                            cancel = true
                        }
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .buttonStyle(.plain)
                        .confirmationDialog("Cancel new map", isPresented: $cancel) {
                            Button("Cancel new map", role: .destructive) {
                                session.flow = .main
                            }
                            
                            Button("Continue", role: .cancel) {
                                cancel = false
                            }
                        }
                        
                        Button {
                            
                        } label: {
                            Text("Save")
                                .font(.callout)
                                .padding(.horizontal, 5)
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundColor(Color(.systemBackground))
                        .tint(.primary)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 5)
                    
                    Divider()
                        .padding(.horizontal)
                        
                    HStack(spacing: 0) {
                        Action(symbol: "questionmark.circle") {
                            
                        }
                        
                        Action(symbol: "slider.horizontal.3") {
                            
                        }
                        
                        Button {
                            search = true
                        } label: {
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(.tertiary)
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.primary)
                                    .padding(.leading, 10)
                            }
                            .frame(width: 80, height: 34)
                        }
                        .padding(.horizontal, 15)
                        .sheet(isPresented: $search) {
                            Search { item in
                                Task {
                                    guard
                                        let response = try? await MKLocalSearch(request: .init(completion: item)).start(),
                                        let placemark = response.mapItems.first?.placemark
                                    else { return }
                                    map.addAnnotation(placemark)
                                    map.setCenter(placemark.coordinate, animated: true)
                                    map.selectAnnotation(placemark, animated: true)
                                }
                            }
                        }
                        
                        Action(symbol: "square.stack.3d.up") {
                            
                        }
                        
                        Action(symbol: "location.viewfinder") {
                            let manager = CLLocationManager()
                            switch manager.authorizationStatus {
                            case .denied, .restricted:
                                UIApplication.shared.settings()
                            case .notDetermined:
                                map.first = true
                                manager.requestAlwaysAuthorization()
                            case .authorizedAlways, .authorizedWhenInUse:
                                map.setUserTrackingMode(.follow, animated: true)
                            @unknown default:
                                break
                            }
                        }
                    }
                    .padding(.bottom, 10)
                }
            }
    }
}
