import SwiftUI
import MapKit

struct Create: View {
    @State private var search = false
    private let map = Map()
    
    var body: some View {
        map
            .equatable()
            .edgesIgnoringSafeArea([.top, .leading, .trailing])
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack {
                    Button {
                        
                    } label: {
                        Text("Cancel")
                            .font(.callout)
                            .padding(.horizontal, 5)
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(.bordered)
                    .padding(.leading)
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("Save")
                            .font(.callout)
                            .padding(.horizontal, 5)
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(Color(.systemBackground))
                    .tint(.primary)
                    .padding(.trailing)
                }
                .padding(.top)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    Divider()
                        .edgesIgnoringSafeArea(.horizontal)
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
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(.primary)
                                    .padding(.leading, 10)
                            }
                            .frame(width: 110, height: 34)
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
                                
//                                MKLocalSearch(request: .init(completion: $0)).start { [weak self] in
//                                    guard $1 == nil, let placemark = $0?.mapItems.first?.placemark, let mark = self?.map.add(placemark.coordinate) else { return }
//                                    mark.path.name = placemark.name ?? placemark.title ?? ""
//                                    self?.map.selectAnnotation(mark, animated: true)
//                                    self?.refresh()
//                                }
                            }
                        }
                        
                        Action(symbol: "location.viewfinder") {
                            
                        }
                    }
                    .padding(.vertical, 10)
                    
                    Divider()
                        .edgesIgnoringSafeArea(.horizontal)
                    
                    Text("0 points")
                        .font(.callout)
                        .padding(.vertical)
                        .padding(.leading, 30)
                        .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                }
            }
    }
}
