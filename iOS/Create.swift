import SwiftUI

struct Create: View {
    let session: Session
    @StateObject private var builder = Builder()
    @FocusState private var focus: Bool
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        builder
            .map
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Button(role: .destructive) {
                            UIApplication.shared.hide()
                            builder.cancel = true
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .light))
                                .symbolRenderingMode(.hierarchical)
                        }
                        .foregroundStyle(.secondary)
                        .frame(width: 70)
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
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.secondarySystemFill))
                                .onTapGesture {
                                    builder.map.follow = false
                                    focus.toggle()
                                }
                            
                            HStack {
                                Image(systemName: "character.cursor.ibeam")
                                    .font(.system(size: 14, weight: .light))
                                    .symbolRenderingMode(.hierarchical)
                                
                                TextField("Map title", text: $builder.title)
                                    .font(.body)
                                    .disableAutocorrection(true)
                                    .focused($focus)
                                    .padding(.trailing)
                            }
                            .padding(10)
                            
                            if focus && !builder.title.isEmpty {
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        builder.title = ""
                                    } label: {
                                        Image(systemName: "xmark.square.fill")
                                            .font(.system(size: 22, weight: .light))
                                            .symbolRenderingMode(.hierarchical)
                                            .frame(width: 40, height: 32)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        
                        Button("Save") {
                            UIApplication.shared.hide()
                            builder.map.follow = false
                            
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
                        .padding(.horizontal)
                        .font(.title3.weight(.medium))
                        .buttonStyle(.borderedProminent)
                        .foregroundColor(Color(.systemBackground))
                        .tint(.primary)
                        .disabled(builder.points.count < 2 || builder.overflow)
                    }
                    .padding(.vertical)
                    
                    Divider()
                    
                    ZStack {
                        Rectangle()
                            .fill(Color(.quaternarySystemFill))
                        HStack(alignment: .bottom, spacing: 0) {
                            Text(builder.points.count.formatted())
                                .font(.body.monospacedDigit())
                                .padding(.leading)
                            Text(builder.points.count == 1 ? " marker" : " markers")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                            
                            Spacer()
                            
                            if !builder.route.isEmpty {
                                Text("Duration ")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                
                                Text(Date(timeIntervalSinceNow: -builder.route.duration) ..< Date.now, format: .timeDuration)
                                    .font(.callout.monospacedDigit())
                                
                                Text("Distance ")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading)
                                
                                Text(Measurement(value: builder.route.distance, unit: UnitLength.meters),
                                     format: .measurement(width: .abbreviated))
                                    .font(.callout.monospacedDigit())
                                    .padding(.trailing)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    
                    Divider()
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    Divider()
                    
                    if builder.overflow {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40, weight: .thin))
                            .symbolRenderingMode(.hierarchical)
                            .padding(.top)
                        Text("Map too big")
                            .font(.title3.weight(.regular))
                            .padding(.top, 10)
                        Text("Try a smaller map with\npoints closer to each other")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                        Divider()
                            .padding(.horizontal)
                    }
                    
                    HStack(spacing: 0) {
                        Action(symbol: "questionmark.circle") {
                            UIApplication.shared.hide()
                            builder.help = true
                        }
                        .sheet(isPresented: $builder.help, content: Help.init)
                        
                        Action(symbol: "slider.horizontal.3") {
                            UIApplication.shared.hide()
                            builder.map.follow = false
                            builder.config = true
                        }
                        .sheet(isPresented: $builder.config) {
                            Sheet(rootView: Config(builder: builder))
                        }
                        
                        Button {
                            UIApplication.shared.hide()
                            builder.map.follow = false
                            builder.search = true
                        } label: {
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(.secondarySystemFill))
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.primary)
                                    .padding(.leading, 10)
                            }
                            .frame(width: 80, height: 38)
                        }
                        .padding(.horizontal, 10)
                        .sheet(isPresented: $builder.search) {
                            Search { item in
                                Task {
                                    await builder.selected(completion: item)
                                }
                            }
                        }
                        
                        Action(symbol: "square.stack.3d.up") {
                            UIApplication.shared.hide()
                            builder.map.follow = false
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
                    .frame(height: 62)
                }
            }
            .preferredColorScheme(builder.color)
            .ignoresSafeArea(.keyboard)
    }
}
