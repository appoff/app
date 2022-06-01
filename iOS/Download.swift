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
            } else {
                Text("Please wait")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if let error = error {
                if error as? Syncher.Error != Syncher.Error.unsynched {
                    Button {
                        self.error = nil
                        
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
                }
                
                Button(role: .destructive) {
                    UIApplication.shared.isIdleTimerDisabled = false
                    
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
                .padding(.bottom, 30)
            }
        }
        .task {
            UIApplication.shared.isIdleTimerDisabled = true
            
            try? await Task.sleep(nanoseconds: 450_000_000)
            session.selected = nil
            
            await download()
        }
    }
    
    @MainActor private func download() async {
        do {
            try await cloud.add(header: syncher.header, schema: syncher.download())
            
            UIApplication.shared.isIdleTimerDisabled = false
            
            withAnimation(.easeInOut(duration: 0.4)) {
                session.flow = .downloaded(syncher.header)
            }
        } catch {
            self.error = error
        }
    }
}
