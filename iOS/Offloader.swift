import Offline

import CloudKit

public struct Offloader {
    private let container = CKContainer(identifier: "iCloud.offline")
    
    public init() { }
    
    public func exists(header: Header) async throws -> Bool {
        guard .available == (try await container.accountStatus()) else { throw Error.unavailable }
        
        return false
    }
}
