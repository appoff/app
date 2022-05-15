import SwiftUI
import Offline

struct Detail: View {
    let session: Session
    let map: Offline.Map
    let namespace: Namespace.ID
    let thumbnail: UIImage?
    @State private var opacity = Double()
    @State private var data = Data()
    @State private var delete = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(.tertiarySystemBackground))
                .matchedGeometryEffect(id: "background", in: namespace)
                .edgesIgnoringSafeArea(.bottom)
            VStack {
                ZStack(alignment: .top) {
                    if let thumbnail = thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .matchedGeometryEffect(id: "image", in: namespace)
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        
                    }
                    HStack {
                        Button("Delete", role: .destructive) {
                            delete = true
                        }
                        .font(.callout)
                        .tint(Color(.systemBackground))
                        .foregroundColor(.primary)
                        .buttonStyle(.bordered)
                        .confirmationDialog("Delete map?", isPresented: $delete) {
                            Button("Cancel", role: .cancel) { }
                            Button("Delete", role: .destructive) {
                                dismiss()
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: dismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28, weight: .light))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.primary, Color(.systemBackground).opacity(0.5))
                                .frame(width: 50, height: 50)
                        }
                        .opacity(opacity)
                    }
                    .padding([.top, .leading, .trailing], 20)
                }
                Info(map: map, size: data.count)
                    .matchedGeometryEffect(id: "info", in: namespace)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("Open")
                        .font(.body.bold())
                        .frame(maxWidth: .greatestFiniteMagnitude)
                        .frame(minHeight: 32)
                }
                .tint(.primary)
                .foregroundColor(.init(.systemBackground))
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .matchedGeometryEffect(id: "card", in: namespace)
        .edgesIgnoringSafeArea([.top, .leading, .trailing])
        .gesture(
            DragGesture(minimumDistance: 80)
                .onChanged { gesture in
                    dismiss()
                }
        )
        .statusBar(hidden: true)
        .task {
            data = await session.local.load(map: map) ?? .init()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                opacity = 1
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.4)) {
            session.selected = nil
        }
    }
}
