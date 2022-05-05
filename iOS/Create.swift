import SwiftUI

struct Create: View {
    @State private var search = false
    
    var body: some View {
        Map()
            .edgesIgnoringSafeArea([.top, .leading, .trailing])
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    Divider()
                        .edgesIgnoringSafeArea(.horizontal)
                    HStack(spacing: 0) {
                        Action(symbol: "questionmark.circle") {
                            
                        }
                        .padding(.leading)
                        
                        Action(symbol: "slider.horizontal.3") {
                            
                        }
                        
                        Action(symbol: "location.viewfinder") {
                            
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
                            .frame(width: 68, height: 34)
                        }
                        .padding(.leading, 10)
                        .sheet(isPresented: $search, content: Search.init)
                        
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
