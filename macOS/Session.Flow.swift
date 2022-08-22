import AppKit
import Offline

extension Session {
    enum Flow {
        case
        main,
        create,
        scan,
        loading(Factory),
        unzip(Project),
        offload(Header),
        download(Header),
        share(Header),
        shared(Header, NSImage),
        navigate(Schema, Bufferer)
    }
}
