@testable import Offline

import CoreImage
import CloudKit
import Network

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
        config.timeoutIntervalForRequest = 600
        config.timeoutIntervalForResource = 600
        config.allowsCellularAccess = false
        config.qualityOfService = .userInitiated
    }
    
    public func share() throws -> CGImage {
        print(header.wrapped.count)
        guard
            let filter = CIFilter(name: "CIQRCodeGenerator", parameters: [
                "inputCorrectionLevel" : "H",
                "inputMessage" : header.wrapped]),
            let raw = filter
                .outputImage?
                .transformed(by: .init(scaleX: 10, y: 10)),
            let image = CIContext()
                .createCGImage(raw, from: raw.extent)
        else { throw Error.generate }
        return image
    }
    
    public func load(image: CGImage) throws {
        guard
            let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                      context: nil,
                                      options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
            let header = Header
                .unwrap(data: .init(detector
                    .features(in: .init(cgImage: image))
                    .compactMap({ $0 as? CIQRCodeFeature })
                    .compactMap(\.messageString)
                    .flatMap({ Data($0.utf8) })))
        else { throw Error.importing }
        
        
    }
    
    public func upload(schema: Schema) async throws {
        try network()
        try await available()
        
        try await container.database.configuredWith(configuration: config) { base in
            let record = CKRecord(recordType: "Map", recordID: .init(recordName: header.id.uuidString))
            record[_id] = header.id.uuidString
            record[_schema] = schema.data
            record[_payload] = CKAsset(fileURL: local.url(header: header))
            
            guard
                let result = (try await base
                    .modifyRecords(saving: [record],
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
        }
    }
    
    public func delete() {
        local.delete(header: header)
    }
    
    public func download() async throws -> Schema {
        try network()
        try await available()
        
        return try await container.database.configuredWith(configuration: config) { base in
            do {
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
            } catch {
                if (error as? CKError)?.code == .unknownItem {
                    throw Error.unsynched
                }
                throw error
            }
        }
    }
    
    private func available() async throws {
        if try await container.accountStatus() != .available {
            throw Error.unavailable
        }
    }
    
    private func network() throws {
        let path = NWPathMonitor(prohibitedInterfaceTypes: [.cellular]).currentPath
        if path.status != .satisfied || path.isExpensive {
            throw Error.network
        }
    }
}
