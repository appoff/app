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
        navigate(Schema, Bufferer)
    }
}
