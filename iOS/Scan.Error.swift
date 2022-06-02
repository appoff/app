import Foundation

extension Scan {
    enum Error: LocalizedError {
        case
        existing,
        invalid
        
        public var errorDescription: String? {
            switch self {
            case .existing:
                return "You already have this map."
            case .invalid:
                return "Could not load the image, try a different one."
            }
        }
    }
}
