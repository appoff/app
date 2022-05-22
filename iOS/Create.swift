import SwiftUI

struct Create: View {
    let session: Session
    @StateObject private var builder = Builder()
    @FocusState private var focus: Bool
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        builder
            .map
            .edgesIgnoringSafeArea([.top, .leading, .trailing])
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    Divider()
                        .edgesIgnoringSafeArea(.horizontal)
                    
                    HStack {
                        Button {
                            focus.toggle()
                        } label: {
                            Image(systemName: "character.cursor.ibeam")
                                .font(.system(size: 20, weight: .light))
                                .symbolRenderingMode(.hierarchical)
                        }
                        
                        TextField("Map title", text: $builder.title)
                            .font(.callout)
                            .textFieldStyle(.roundedBorder)
                            .focused($focus)
                            .padding(.trailing)
                        
                        Spacer()
                        
                        Button("Cancel", role: .destructive) {
                            builder.cancel = true
                        }
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .buttonStyle(.plain)
                        .confirmationDialog("Cancel map", isPresented: $builder.cancel) {
                            Button("Cancel map", role: .destructive) {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    session.flow = .main
                                }
                            }
                            
                            Button("Continue", role: .cancel) {
                                builder.cancel = false
                            }
                        }
                        
                        Button("Save") {
                            Task {
                                var settings = await cloud.model.settings
                                if settings.scheme == .auto {
                                    switch scheme {
                                    case .light:
                                        settings.scheme = .light
                                    case .dark:
                                        settings.scheme = .dark
                                    @unknown default:
                                        break
                                    }
                                }
                                
                                withAnimation(.easeIn(duration: 0.4)) {
                                    session.flow = .loading(builder.factory(settings: settings))
                                }
                            }
                        }
                        .font(.title3.weight(.medium))
                        .buttonStyle(.borderedProminent)
                        .foregroundColor(Color(.systemBackground))
                        .tint(.primary)
                        .disabled(builder.points.count < 2)
                        .padding(.leading)
                        .padding(.vertical, 15)
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
                            
                            Text(Date(timeIntervalSinceNow: -builder.route.duration) ..< Date.now, format: .timeDuration)
                                .font(.footnote.monospacedDigit())
                                .foregroundStyle(.secondary)
                            
                            Text("Distance ")
                                .font(.caption)
                                .padding(.leading)
                            
                            Text(Measurement(value: builder.route.distance, unit: UnitLength.meters),
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
                        
                        Action(symbol: "slider.vertical.3") {
                            builder.config = true
                        }
                        .sheet(isPresented: $builder.config) {
                            Sheet(rootView: Config(builder: builder))
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
                            builder.options = true
                        }
                        .sheet(isPresented: $builder.options) {
                            Sheet(rootView: Options(builder: builder))
                        }
                        
                        Action(symbol: "location.viewfinder", action: builder.tracker)
                    }
                    .padding(.bottom, 12)
                }
            }
            .preferredColorScheme(builder.color)
    }
}
