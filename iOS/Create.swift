import SwiftUI

struct Create: View {
    let session: Session
    @StateObject private var builder = Builder()
    
    var body: some View {
        builder
            .map
            .edgesIgnoringSafeArea([.top, .leading, .trailing])
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    Divider()
                        .edgesIgnoringSafeArea(.horizontal)
                    
                    HStack {
                        Text(builder.points.count.formatted() + " points")
                            .font(.callout)
                            .padding(.leading)
                        
                        Spacer()
                        
                        Button("Cancel", role: .destructive) {
                            builder.cancel = true
                        }
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .buttonStyle(.plain)
                        .confirmationDialog("Cancel new map", isPresented: $builder.cancel) {
                            Button("Cancel new map", role: .destructive) {
                                session.flow = .main
                            }
                            
                            Button("Continue", role: .cancel) {
                                builder.cancel = false
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
                    .padding(.vertical, 10)
                    
                    Divider()
                        .padding(.horizontal)
                        
                    HStack(spacing: 0) {
                        Action(symbol: "questionmark.circle") {
                            
                        }
                        
                        Action(symbol: "slider.horizontal.3") {
                            
                        }
                        
                        Button {
                            builder.search = true
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
                        .sheet(isPresented: $builder.search) {
                            Search { item in
                                Task {
                                    await builder.selected(completion: item)
                                }
                            }
                        }
                        
                        Action(symbol: "square.stack.3d.up") {
                            
                        }
                        
                        Action(symbol: "location.viewfinder", action: builder.tracker)
                    }
                    .padding(.bottom, 10)
                }
            }
    }
}
