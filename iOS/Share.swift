import SwiftUI
import CloudKit
import Offline

struct Share: View {
    let session: Session
    let syncher: Syncher
    @State private var error: Error?
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 60, weight: .ultraLight))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)
            
            if error == nil {
                Text("Sharing")
                    .font(.title2.weight(.regular))
                    .padding(.top)
            }
            
            Text(syncher.header.title)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: 280)
            
            if let error = error {
                Text((error as? CKError)?.localizedDescription ?? error.localizedDescription)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 280)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 20)
            } else {
                Text("Please wait")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if error != nil {
                Button {
                    error = nil
                    
                    Task {
                        await share()
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
                    UIApplication.shared.isIdleTimerDisabled = false
                    
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
            UIApplication.shared.isIdleTimerDisabled = true
            
            try? await Task.sleep(nanoseconds: 450_000_000)
            session.selected = nil
            
            await share()
        }
    }
    
    @MainActor private func share() async {
        if let schema = await cloud.model.projects.first(where: { $0.id == syncher.header.id })?.schema {
            do {
                try await syncher.upload(schema: schema)
            } catch {
                self.error = error
                return
            }
        } else {
            fatalError()
        }
        
        UIApplication.shared.isIdleTimerDisabled = false
        
        withAnimation(.easeInOut(duration: 0.4)) {
            session.flow = .offloaded(syncher.header)
        }
        //
        //        do {
        //
        //            await cloud.offload(header: syncher.header)
        //            syncher.delete()
        //
        //            UIApplication.shared.isIdleTimerDisabled = false
        //
        //            withAnimation(.easeInOut(duration: 0.4)) {
        //                session.flow = .offloaded(syncher.header)
        //            }
        //        } catch {
        //            self.error = error
        //        }
    }
}



/*
 public class func export(_ board:Board) -> CGImage {
     let filter = CIFilter(name:"CIQRCodeGenerator")!
     filter.setValue("H", forKey:"inputCorrectionLevel")
     filter.setValue(Data(board.id.utf8), forKey:"inputMessage")
     let ciImage = filter.outputImage!.transformed(by:CGAffineTransform(scaleX:14, y:14))
     return CIContext().createCGImage(ciImage, from:ciImage.extent)!
 }
 */
