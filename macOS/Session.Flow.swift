import AppKit
import Offline

extension Session {
    enum Flow {
        case
        main,
        create,
        scan,
        selected(Project),
        loading(Factory),
        created(Header),
        unzip(Project),
        offload(Header),
        download(Header),
        share(Header),
        shared(Header, NSImage),
        navigate(Schema, Bufferer)
    }
}
