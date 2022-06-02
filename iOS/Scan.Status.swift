import SwiftUI

extension Scan {
    final class Status: ObservableObject {
        @Published var video = true
        @Published var image: UIImage?
        @Published var error: Swift.Error?
    }
}
