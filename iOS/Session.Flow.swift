import MapKit
import Offline

extension Session {
    enum Flow {
        case
        main,
        create,
        created(Offline.Map),
        deleted(Offline.Map),
        loading(Factory),
        unzip(Item),
        navigate(Signature, Tiles)
    }
}
