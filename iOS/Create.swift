import SwiftUI

struct Create: View {
    var body: some View {
        Map()
            .edgesIgnoringSafeArea([.top, .leading, .trailing])
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    Divider()
                        .edgesIgnoringSafeArea(.horizontal)
                    HStack {
                        Action(symbol: "questionmark.circle") {
                            
                        }
                        .padding(.leading)
                        
                        Action(symbol: "slider.horizontal.3") {
                            
                        }
                        
                        Action(symbol: "arrow.triangle.turn.up.right.circle") {
                            
                        }
                        
                        Action(symbol: "location.viewfinder") {
                            
                        }
                        
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
