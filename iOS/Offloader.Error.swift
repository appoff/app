import Foundation
extension Offloader {
    enum Error: LocalizedError {
        case
        unavailable
        
        var errorDescription: String? {
            switch self {
            case .unavailable:
                return "iCloud unreachable, check that you are logged into your account or try again later."
            }
        }
    }
}
