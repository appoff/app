import MapKit
import Offline

extension Session {
    enum Flow {
        case
        main,
        create,
        loading(Factory)
    }
}
