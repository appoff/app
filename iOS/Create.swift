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
                    
                    if builder.overflow {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40, weight: .thin))
                            .symbolRenderingMode(.hierarchical)
                            .padding(.top)
                        Text("Map too big")
                            .font(.title3.weight(.regular))
                            .padding(.top, 10)
                        Text("Try a smaller map with\npoints closer to each other")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                        Divider()
                            .padding(.horizontal)
                    }
                    
                    HStack {
                        Button {
                            focus.toggle()
                        } label: {
                            Image(systemName: "character.cursor.ibeam")
                                .font(.system(size: 22, weight: .light))
                                .symbolRenderingMode(.hierarchical)
                        }
                        
                        TextField("Map title", text: $builder.title)
                            .font(.body)
                            .textFieldStyle(.roundedBorder)
                            .focused($focus)
                            .padding(.trailing)
                        
                        Spacer()
                        
                        Button("Cancel", role: .destructive) {
                            UIApplication.shared.hide()
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
                            UIApplication.shared.hide()
                            
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
                        .disabled(builder.points.count < 2 || builder.overflow)
                        .padding(.leading)
                        .padding(.vertical, 16)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)

                    HStack(spacing: 0) {
                        Text(builder.points.count.formatted())
                            .font(.body.monospacedDigit())
                        + Text(builder.points.count == 1 ? " point" : " points")
                            .foregroundColor(.secondary)
                            .font(.callout)
                        
                        Spacer()
                        
                        if !builder.route.isEmpty {
                            Text("Duration ")
                                .font(.footnote)
                            
                            Text(Date(timeIntervalSinceNow: -builder.route.duration) ..< Date.now, format: .timeDuration)
                                .font(.callout.monospacedDigit())
                                .foregroundStyle(.secondary)
                            
                            Text("Distance ")
                                .font(.footnote)
                                .padding(.leading)
                            
                            Text(Measurement(value: builder.route.distance, unit: UnitLength.meters),
                                 format: .measurement(width: .abbreviated))
                                .font(.callout.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .padding(.vertical, 4)
                    
                    Divider()
                        .padding(.horizontal)
                        
                    HStack(spacing: 0) {
                        Action(symbol: "questionmark.circle") {
                            UIApplication.shared.hide()
                        }
                        
                        Action(symbol: "slider.horizontal.3") {
                            UIApplication.shared.hide()
                            builder.config = true
                        }
                        .sheet(isPresented: $builder.config) {
                            Sheet(rootView: Config(builder: builder))
                        }
                        
                        Button {
                            UIApplication.shared.hide()
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
                        .padding(.horizontal, 16)
                        .sheet(isPresented: $builder.search) {
                            Search { item in
                                Task {
                                    await builder.selected(completion: item)
                                }
                            }
                        }
                        
                        Action(symbol: "square.stack.3d.up") {
                            UIApplication.shared.hide()
                            builder.options = true
                        }
                        .sheet(isPresented: $builder.options) {
                            Sheet(rootView: Options(builder: builder))
                        }
                        
                        Action(symbol: "location.viewfinder") {
                            UIApplication.shared.hide()
                            builder.tracker()
                        }
                    }
                    .padding(.bottom, 12)
                }
            }
            .preferredColorScheme(builder.color)
    }
}
