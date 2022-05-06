import SwiftUI

struct Main: View {
    let session: Session
    @State private var search = ""
    @State private var maps = [Item]()
    
    var body: some View {
        ScrollView {
//            if !session.authorized {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 16, style: .continuous)
//                        .stroke(.tertiary, lineWidth: 1)
//                    VStack(spacing: 10) {
//                        Image(systemName: "location.viewfinder")
//                            .font(.system(size: 30, weight: .ultraLight))
//                        Text("Activate your location\nto get navigation")
//                            .font(.callout)
//                            .fixedSize(horizontal: false, vertical: true)
//                            .multilineTextAlignment(.center)
//                        Button {
//                            if session.manager.authorizationStatus == .denied || session.manager.authorizationStatus == .restricted {
//                                UIApplication.shared.settings()
//                            } else {
//                                session.manager.requestAlwaysAuthorization()
//                            }
//                        } label: {
//                            Text("Activate")
//                                .font(.callout)
//                                .padding(.horizontal, 6)
//                        }
//                        .buttonStyle(.borderedProminent)
//                    }
//                    .padding()
//                }
//                .padding()
//            }
            
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
                    session.flow = .create
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .regular))
                        .frame(minWidth: 40, minHeight: 30)
                        .contentShape(Rectangle())
                }
            }
        }
    }
}
