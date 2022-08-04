import Combine
import StoreKit

final class Session {
    let loading = CurrentValueSubject<_, Never>(true)
    private var reviewed = false
    private var subs = Set<AnyCancellable>()
    
    init() {
        
    }
    
    func review() {
        #if !DEBUG
        if Defaults.ready && !reviewed {
            SKStoreReviewController.requestReview()
            reviewed = true
        }
        #endif
    }
}
