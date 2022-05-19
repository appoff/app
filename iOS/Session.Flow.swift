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
        unzip(Offline.Map, Data),
        navigate(Tiles)
    }
}
