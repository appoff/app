import Combine
import StoreKit
import Offline

final class Session {
    let loading = CurrentValueSubject<_, Never>(true)
    let filtered = CurrentValueSubject<[Project], Never>([])
    let search = CurrentValueSubject<_, Never>("")
    let flow = CurrentValueSubject<_, Never>(Flow.main)
    let cancel = PassthroughSubject<Void, Never>()
    let title = CurrentValueSubject<_, Never>("")
    private var reviewed = false
    private var subs = Set<AnyCancellable>()
    
    init() {
        cloud
            .combineLatest(search) {
                $0.projects.filtered(search: $1)
            }
            .sink { [weak self] in
                self?.filtered.value = $0
            }
            .store(in: &subs)
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
