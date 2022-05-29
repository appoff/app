import Foundation
extension Offloader {
    public enum Error: LocalizedError {
        case
        unavailable,
        offloaded
        
        public var errorDescription: String? {
            switch self {
            case .unavailable:
                return "iCloud unreachable, check that you are logged into your account or try again later."
            case .offloaded:
                return "Seems like you haven't downloaded this map yet."
            }
        }
    }
}
