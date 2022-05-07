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
                        
                        Button("Save") {
                            
                        }
                        .font(.callout)
                        .buttonStyle(.borderedProminent)
                        .foregroundColor(Color(.systemBackground))
                        .tint(.primary)
                        .padding(.leading)
                        .padding(.vertical, 10)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    
                    HStack(spacing: 0) {
                        Text(builder.points.count.formatted())
                            .font(.callout.monospacedDigit())
                        + Text(builder.points.count == 1 ? " point" : " points")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                        
                        Spacer()
                        
                        if !builder.route.isEmpty {
                            Text("Duration ")
                                .font(.caption)
                            
                            Text(Date(timeIntervalSinceNow: -builder.route.map(\.route.expectedTravelTime).reduce(0, +)) ..< Date.now, format: .timeDuration)
                                .font(.footnote.monospacedDigit())
                                .foregroundStyle(.secondary)
                            
                            Text("Distance ")
                                .font(.caption)
                                .padding(.leading)
                            
                            Text(Measurement(value: builder.route.map(\.route.distance).reduce(0, +), unit: UnitLength.meters),
                                 format: .measurement(width: .abbreviated))
                                .font(.footnote.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    
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
