import SwiftUI
import Offline

struct Download: View {
    let session: Session
    let syncher: Syncher
    @State private var error: Error?
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "icloud.and.arrow.down")
                .font(.system(size: 60, weight: .ultraLight))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)
            
            if error == nil {
                Text("Downloading")
                    .font(.title2.weight(.regular))
                    .padding(.top)
            }
            
            Text(syncher.header.title)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: 280)
            
            if let error = error {
                Text(error.localizedDescription)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 280)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 20)
            }
            
            Spacer()
            
            if error != nil {
                Button {
                    error = nil
                    
                    Task {
                        await download()
                    }
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
                        .foregroundColor(.primary)
                        .padding()
                        .contentShape(Rectangle())
                }
                .padding(.bottom, 30)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 450_000_000)
            session.selected = nil
            
            await download()
        }
    }
    
    private func download() async {
        do {
            try await cloud.add(header: syncher.header, schema: syncher.download())
            
            withAnimation(.easeInOut(duration: 0.4)) {
                session.flow = .main
            }
        } catch {
            self.error = error
        }
    }
}
