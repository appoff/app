@testable import Offline

import CloudKit

public struct Offloader {
    public let header: Header
    private let container = CKContainer(identifier: "iCloud.offline")
    private let config = CKOperation.Configuration()
    private let local = Local()
    
    public init(header: Header) {
        self.header = header
        config.timeoutIntervalForRequest = 300
        config.timeoutIntervalForResource = 300
        config.allowsCellularAccess = false
        config.qualityOfService = .userInitiated
    }
    
    public func save(schema: Schema) async throws {
        guard .available == (try await container.accountStatus()) else { throw Error.unavailable }
        try await container.database.configuredWith(configuration: config) { base in
            
            
            let record = CKRecord(recordType: "Map", recordID: .init(recordName: header.id.uuidString))
//            record["Schema"] = CKAsset
            record["Payload"] = CKAsset(fileURL: local.url(header: header))
            _ = try? await base.modifyRecords(saving: [record],
                                              deleting: [],
                                              savePolicy: .allKeys,
                                              atomically: true)
            
            try await base.record(for: .init(recordName: ""))
        }
        
        
        
        
        /*
         Task { [weak self] in
             let result = await container.database.configured(with: config) { base -> Output? in
                 guard
                     let record = try? await base.record(for: id),
                     let asset = record[Asset] as? CKAsset,
                     let fileURL = asset.fileURL,
                     let data = try? Data(contentsOf: fileURL)
                 else {
                     return nil
                 }
                 return await .prototype(data: data)
             }
             self?.remote.send(result)
         }
         */
    }
}
