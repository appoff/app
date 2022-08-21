import StoreKit

extension App {
    final class Delegate: NSObject, UIApplicationDelegate, SKPaymentTransactionObserver {
        func application(_ application: UIApplication, willFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            application.registerForRemoteNotifications()
            SKPaymentQueue.default().add(self)
            return true
        }
        
        func application(_: UIApplication, didReceiveRemoteNotification: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
            await cloud.notified ? .newData : .noData
        }
        
        func paymentQueue(_: SKPaymentQueue, shouldAddStorePayment: SKPayment, for product: SKProduct) -> Bool {
            Task
                .detached {
                    await store.purchase(legacy: product)
                }
            return false
        }
        
        func paymentQueue(_: SKPaymentQueue, updatedTransactions: [SKPaymentTransaction]) {
    
        }
    }
}
