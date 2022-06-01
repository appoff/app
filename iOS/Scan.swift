import SwiftUI

struct Scan: View {
    let session: Session
    @StateObject private var picker = Picker()
    @State private var pick = false
    @State private var title: String?
    @State private var error: Error?
    
    var body: some View {
        VStack {
            if let image = picker.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding([.leading, .trailing, .top])
                    .frame(maxHeight: 200)
                    .task {
                        guard let raw = image.cgImage else { return }
                        
                        do {
                            let header = try Syncher.load(image: raw)
                            title = header.title
                            Task {
                                if await cloud.model.projects.contains(where: { $0.header.id == header.id }) {
                                    error = Syncher.Error.existing
                                } else {
                                    
                                }
                            }
                        } catch {
                            self.error = error
                        }
                    }
                
                if let title = title {
                    Text(title)
                        .font(.callout)
                        .lineLimit(1)
                        .frame(maxWidth: 280)
                        .padding(.top)
                }
                
                if error == nil {
                    Text("Loading")
                        .font(.title2.weight(.regular))
                        .padding(.top)
                }
                
                if let error = error {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50, weight: .ultraLight))
                        .symbolRenderingMode(.hierarchical)
                        .padding(.vertical)
                    
                    Text(error.localizedDescription)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 280)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    Button {
                        title = nil
                        self.error = nil
                        picker.image = nil
                    } label: {
                        Text("Try again")
                            .font(.body.weight(.bold))
                            .foregroundColor(.primary)
                            .padding()
                            .contentShape(Rectangle())
                    }
                    .padding(.bottom)
                    
                    Button(role: .destructive) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            session.flow = .main
                        }
                    } label: {
                        Text("Cancel")
                            .font(.callout.weight(.medium))
                            .foregroundColor(.secondary)
                            .padding()
                            .contentShape(Rectangle())
                    }
                }
            } else {
                Text("Camera")
            }
            Spacer()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if picker.image == nil {
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 30) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                session.flow = .main
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 24, weight: .light))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.primary)
                                .frame(width: 60, height: 60)
                                .contentShape(Rectangle())
                        }
                        
                        Button {
                            pick = true
                        } label: {
                            Image(systemName: "photo.circle.fill")
                                .font(.system(size: 42, weight: .thin))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.primary)
                                .frame(width: 60, height: 60)
                                .contentShape(Rectangle())
                        }
                        .sheet(isPresented: $pick) {
                            picker
                        }
                        
                        Button {
                            session.flow = .scan
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 24, weight: .light))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.primary)
                                .frame(width: 60, height: 60)
                                .contentShape(Rectangle())
                        }
                    }
                    .padding(.vertical, 3)
                }
                .background(.regularMaterial)
            }
        }
    }
}
