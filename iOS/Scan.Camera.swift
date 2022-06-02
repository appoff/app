import SwiftUI
import AVFoundation

extension Scan {
    final class Camera: UIView, UIViewRepresentable, AVCaptureMetadataOutputObjectsDelegate {
        weak var status: Status?
        private let session: AVCaptureSession
//        private let preview: AVCaptureVideoPreviewLayer
        
        required init?(coder: NSCoder) { nil }
        @MainActor init() {
            session = .init()
            
            super.init(frame: .zero)
            backgroundColor = .black
            print("camera")
            
            guard let device = AVCaptureDevice.default(for: .video) else {
                status?.video = false
                return
            }
            
            Task {
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
                    layer.addSublayer(preview)

                    session.startRunning()
                } catch {
                    status?.error = error
                }
            }
        }
        
        deinit {
            print("camera gone")
        }
        
        func makeUIView(context: Context) -> Camera {
            self
        }
        
        func updateUIView(_: Camera, context: Context) { }
    }
}

/*
 import AVFoundation
 import UIKit

 class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
     var captureSession: AVCaptureSession!
     var previewLayer: AVCaptureVideoPreviewLayer!

     override func viewDidLoad() {
         super.viewDidLoad()

         view.backgroundColor = UIColor.black
         captureSession = AVCaptureSession()

         guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
         let videoInput: AVCaptureDeviceInput

         do {
             videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
         } catch {
             return
         }

         if (captureSession.canAddInput(videoInput)) {
             captureSession.addInput(videoInput)
         } else {
             failed()
             return
         }

         let metadataOutput = AVCaptureMetadataOutput()

         if (captureSession.canAddOutput(metadataOutput)) {
             captureSession.addOutput(metadataOutput)

             metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
             metadataOutput.metadataObjectTypes = [.qr]
         } else {
             failed()
             return
         }

         previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
         previewLayer.frame = view.layer.bounds
         previewLayer.videoGravity = .resizeAspectFill
         view.layer.addSublayer(previewLayer)

         captureSession.startRunning()
     }

     func failed() {
         let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
         ac.addAction(UIAlertAction(title: "OK", style: .default))
         present(ac, animated: true)
         captureSession = nil
     }

     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)

         if (captureSession?.isRunning == false) {
             captureSession.startRunning()
         }
     }

     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)

         if (captureSession?.isRunning == true) {
             captureSession.stopRunning()
         }
     }

     func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
         captureSession.stopRunning()

         if let metadataObject = metadataObjects.first {
             guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
             guard let stringValue = readableObject.stringValue else { return }
             AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
             found(code: stringValue)
         }

         dismiss(animated: true)
     }

     func found(code: String) {
         print(code)
     }

     override var prefersStatusBarHidden: Bool {
         return true
     }

     override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
         return .portrait
     }
 }
 */
