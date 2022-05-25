import Foundation
import UserNotifications
import Offline

extension Store {
    enum Item: String {
        case
        cloud = "app.offline.cloud"
        
        func purchased(active: Bool) async {
            if active {
                Defaults.cloud = true
                await UNUserNotificationCenter.send(message: "Offline Cloud purchase successful!")
            } else {
                Defaults.cloud = false
            }
        }
    }
}
