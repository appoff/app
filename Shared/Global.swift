import CloudKit
import Archivable
import Offline

let cloud = Cloud<Archive, CKContainer>.new(identifier: "iCloud.offline")

#if os(iOS) || os(macOS)
var store = Store()
#endif
