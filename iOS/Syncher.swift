@testable import Offline

import CloudKit

private let _id = "id"
private let _schema = "schema"
private let _payload = "payload"

public struct Syncher {
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
    
    public func upload(schema: Schema) async throws {
        guard .available == (try await container.accountStatus()) else { throw Error.unavailable }
        try await container.database.configuredWith(configuration: config) { base in
            let record = CKRecord(recordType: "Map", recordID: .init(recordName: header.id.uuidString))
            record[_id] = header.id.uuidString
            record[_schema] = schema.data
            record[_payload] = CKAsset(fileURL: local.url(header: header))
            let result = try await base.modifyRecords(saving: [record],
                                              deleting: [],
                                              savePolicy: .ifServerRecordUnchanged,
                                              atomically: true)
            
            switch result.saveResults[.init(recordName: header.id.uuidString)]! {
            case let .failure(error):
                guard (error as? CKError)?.code == .serverRecordChanged else {
                    throw error
                }
            default:
                break
            }
        }
    }
    
    public func download() async throws {
        throw Error.unavailable
    }
    
    public func delete() {
        local.delete(header: header)
    }
}
