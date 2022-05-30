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
        try await available()
        try await container.database.configuredWith(configuration: config) { base in
            let record = CKRecord(recordType: "Map", recordID: .init(recordName: header.id.uuidString))
            record[_id] = header.id.uuidString
            record[_schema] = schema.data
            record[_payload] = CKAsset(fileURL: local.url(header: header))
            
            guard let result = (try await base.modifyRecords(saving: [record],
                                                            deleting: [],
                                                            savePolicy: .ifServerRecordUnchanged,
                                                            atomically: true))
                .saveResults
                .first?
                .value
                    
            else { throw Error.malformed }
            
            if case let .failure(error) = result, (error as? CKError)?.code != .serverRecordChanged {
                throw error
            }
            
            local.delete(header: header)
        }
    }
    
    public func download() async throws -> Schema {
        try await available()
        return try await container.database.configuredWith(configuration: config) { base in
            let record = try await base.record(for: .init(recordName: header.id.uuidString))
            guard
                let schema = record[_schema] as? Data,
                !schema.isEmpty,
                let payload = record[_payload] as? CKAsset,
                let url = payload.fileURL
            else { throw Error.malformed }
            
            let data = try Data(contentsOf: url)
            
            guard !data.isEmpty else { throw Error.malformed }
            
            local.save(header: header, data: data)
            
            return schema.prototype()
        }
    }
    
    private func available() async throws {
        if try await container.accountStatus() != .available {
            throw Error.unavailable
        }
    }
}
