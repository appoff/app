import SwiftUI

extension Scan {
    final class Status: ObservableObject {
        @Published var video = true
        @Published var found: Any?
        @Published var error: Swift.Error?
    }
}
