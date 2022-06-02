import SwiftUI
import AVFoundation

extension Scan {
    final class Camera: UIView, UIViewRepresentable, AVCaptureMetadataOutputObjectsDelegate {
        weak var status: Status?
        private let session: AVCaptureSession
        
        required init?(coder: NSCoder) { nil }
        init() {
            session = .init()
            
            super.init(frame: .zero)
            backgroundColor = .black
            
            let image = UIImageView(image: .init(systemName: "qrcode.viewfinder")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 120, weight: .light)
                    .applying(UIImage.SymbolConfiguration(hierarchicalColor: .secondaryLabel))))
            image.translatesAutoresizingMaskIntoConstraints = false
            image.contentMode = .center
            image.clipsToBounds = true
            addSubview(image)
            
            image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            Task {
                await load()
            }
        }
        
        func metadataOutput(_: AVCaptureMetadataOutput, didOutput: [AVMetadataObject], from: AVCaptureConnection) {
            guard
                status?.found == nil,
                let object = didOutput.first as? AVMetadataMachineReadableCodeObject,
                let string = object.stringValue
            else { return }
            status?.found = Data(string.utf8)
        }
        
        func makeUIView(context: Context) -> Camera {
            self
        }
        
        func updateUIView(_: Camera, context: Context) { }
        
        @MainActor private func load() async {
            guard let device = AVCaptureDevice.default(for: .video) else {
                status?.video = false
                return
            }
            
            guard await AVCaptureDevice.requestAccess(for: .video) else {
                status?.video = false
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                let output = AVCaptureMetadataOutput()
                
                guard
                    session.canAddInput(input),
                    session.canAddOutput(output)
                else {
                    status?.video = false
                    return
                }
                
                session.addInput(input)
                session.addOutput(output)
                
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                output.metadataObjectTypes = [.qr]
                
                let preview = AVCaptureVideoPreviewLayer(session: session)
                preview.frame = layer.bounds
                preview.videoGravity = .resizeAspectFill
                layer.insertSublayer(preview, at: 0)
                
                session.startRunning()
            } catch {
                status?.error = error
            }
        }
    }
}
