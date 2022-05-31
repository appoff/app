import MapKit
import Offline

extension Session {
    enum Flow {
        case
        main,
        create,
        scan,
        created(Header),
        deleted(Header),
        loading(Factory),
        unzip(Project),
        offload(Header),
        download(Header),
        offloaded(Header),
        downloaded(Header),
        share(Header),
        shared(Header, UIImage),
        navigate(Schema, Bufferer)
    }
}
