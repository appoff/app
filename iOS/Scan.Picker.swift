import SwiftUI
import PhotosUI

extension Scan {
    final class Picker: NSObject, PHPickerViewControllerDelegate, UIViewControllerRepresentable {
        weak var status: Status?
        
        func picker(_ picker: PHPickerViewController, didFinishPicking: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard
                let provider = didFinishPicking.first?.itemProvider,
                provider.canLoadObject(ofClass: UIImage.self)
            else { return }
            
            provider
                .loadObject(ofClass: UIImage.self) { [weak self] reading, _ in
                    guard let image = reading as? UIImage else {
                        self?.status?.error = Error.invalid
                        return
                    }
                    
                    self?.status?.image = image
                }
        }
        
        func makeUIViewController(context: Context) -> PHPickerViewController {
            var config = PHPickerConfiguration()
            config.filter = .images
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            return picker
        }

        func updateUIViewController(_: PHPickerViewController, context: Context) {

        }
    }
}
