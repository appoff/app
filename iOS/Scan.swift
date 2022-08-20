import SwiftUI
import Offline

struct Scan: View {
    @StateObject var status: Status
    
    var body: some View {
        VStack {
            if let found = status.found {
                if let image = found as? UIImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding([.leading, .trailing, .top])
                        .frame(maxHeight: 200)
                        .task {
                            guard let raw = image.cgImage else { return }
                            
                            do {
                                try await status.load(header: Syncher.load(image: raw))
                            } catch {
                                status.error = error
                            }
                        }
                } else if let data = found as? Data {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 200, weight: .ultraLight))
                        .symbolRenderingMode(.hierarchical)
                        .padding(.top)
                        .task {
                            do {
                                try await status.load(header: Syncher.load(data: data))
                            } catch {
                                status.error = error
                            }
                        }
                }
                
                if let title = status.title {
                    Text(title)
                        .font(.callout)
                        .lineLimit(1)
                        .frame(maxWidth: 280)
                        .padding(.top)
                }
                
                if status.error == nil {
                    Text("Loading")
                        .font(.title2.weight(.regular))
                        .padding(.top)
                    Spacer()
                }
            } else if status.error == nil {
                if status.video {
                    status.camera
                } else {
                    Spacer()
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 50, weight: .ultraLight))
                        .symbolRenderingMode(.hierarchical)
                        .padding(.bottom)
                    
                    Text("This device can't scan QR Codes, try selecting an image.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 280)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }
            
            if let error = status.error {
                Spacer()
                
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50, weight: .ultraLight))
                    .symbolRenderingMode(.hierarchical)
                    .padding(.bottom)
                
                Text(error.localizedDescription)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 280)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                Button {
                    status.clear()
                } label: {
                    Text("Try again")
                        .font(.body.weight(.bold))
                        .foregroundColor(.primary)
                        .padding()
                        .contentShape(Rectangle())
                }
                .padding(.bottom)
                
                Button(role: .destructive) {
                    withAnimation(.easeIn(duration: 0.4)) {
                        status.session.flow = .main
                    }
                } label: {
                    Text("Cancel")
                        .font(.callout.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding()
                        .contentShape(Rectangle())
                }
                
                Spacer()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if status.found == nil && status.error == nil {
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 30) {
                        Button {
                            if status.camera.session.isRunning {
                                status.camera.session.stopRunning()
                            }
                            
                            withAnimation(.easeIn(duration: 0.4)) {
                                status.session.flow = .main
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .light))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.primary)
                                .frame(width: 60, height: 60)
                                .contentShape(Rectangle())
                        }
                        
                        Button {
                            status.pick = true
                        } label: {
                            Image(systemName: "photo.circle.fill")
                                .font(.system(size: 42, weight: .thin))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.primary)
                                .frame(width: 60, height: 60)
                                .contentShape(Rectangle())
                        }
                        .sheet(isPresented: $status.pick) {
                            status.picker
                        }
                        
                        Button {
                            status.help = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 22, weight: .light))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.primary)
                                .frame(width: 60, height: 60)
                                .contentShape(Rectangle())
                        }
                        .sheet(isPresented: $status.help, content: Help.init)
                    }
                    .frame(height: 62)
                }
                .background(.regularMaterial)
            }
        }
    }
}
