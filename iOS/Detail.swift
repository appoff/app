import SwiftUI
import Offline

struct Detail: View {
    let session: Session
    let project: Project
    let namespace: Namespace.ID
    @State private var opacity = Double()
    @State private var delete = false
    @State private var size = Int()
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(.tertiarySystemBackground))
                .matchedGeometryEffect(id: "background", in: namespace)
                .edgesIgnoringSafeArea(.bottom)
            VStack {
                ZStack(alignment: .top) {
                    if let thumbnail = project.schema.flatMap { UIImage(data: $0.thumbnail) } {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .matchedGeometryEffect(id: "image", in: namespace)
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        
                    }
                    HStack {
                        Button(role: .destructive) {
                            delete = true
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 28, weight: .light))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.primary, Color(.systemBackground))
                                .frame(width: 70, height: 45)
                        }
                        .opacity(opacity)
                        .confirmationDialog("Delete map?", isPresented: $delete) {
                            Button("Cancel", role: .cancel) { }
                            Button("Delete", role: .destructive) {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    session.flow = .deleted(project.header)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: dismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28, weight: .light))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.primary, Color(.systemBackground))
                                .frame(width: 70, height: 45)
                        }
                        .opacity(opacity)
                    }
                    .padding(.top, 40)
                }
                Info(header: project.header, size: size)
                    .matchedGeometryEffect(id: "info", in: namespace)
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        session.flow = .unzip(project)
                    }
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
        .task {
            size = await session.local.size(header: project.header) ?? 0
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
