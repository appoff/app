import Foundation

extension Syncher {
    public enum Error: LocalizedError {
        case
        unavailable,
        offloaded,
        malformed,
        unsynched
        
        public var errorDescription: String? {
            switch self {
            case .unavailable:
                return "iCloud unreachable, check that you are logged into your account or try again later."
            case .offloaded:
                return "Seems like you haven't downloaded this map yet."
            case .malformed:
                return "iCloud response was malformed, try again later."
            case .unsynched:
                return "Seems like this map has not been shared nor offloaded. Try sharing it on the device where it was created."
            }
        }
    }
}