import MapKit
import Offline

extension Session {
    enum Flow {
        case
        main,
        create,
        created(Header),
        deleted(Header),
        loading(Factory),
        unzip(Project),
        offload(Header),
        download(Header),
        offloaded(Header),
        downloaded(Header),
        navigate(Schema, Bufferer)
    }
}
