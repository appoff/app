import CloudKit
import Archivable
import Offline

let limit = Double(110_000)
let cloud = Cloud<Archive, CKContainer>.new(identifier: "iCloud.offline")

#if os(iOS) || os(macOS)
let store = Store()
#endif
