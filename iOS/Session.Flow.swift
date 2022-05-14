import MapKit
import Offline

extension Session {
    enum Flow {
        case
        main,
        create,
        detail(Offline.Map, UIImage?),
        loading(Factory)
    }
}
