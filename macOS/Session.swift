import Combine
import StoreKit
import Offline

final class Session {
    let loading = CurrentValueSubject<_, Never>(true)
    let filtered = CurrentValueSubject<[Project], Never>([])
    let search = CurrentValueSubject<_, Never>("")
    let flow = CurrentValueSubject<_, Never>(Flow.main)
    let cancel = PassthroughSubject<Void, Never>()
    let ready = CurrentValueSubject<_, Never>(false)
    let follow = PassthroughSubject<Void, Never>()
    let current = PassthroughSubject<Void, Never>()
    let find = PassthroughSubject<Void, Never>()
    let settings = PassthroughSubject<NSView, Never>()
    let options = PassthroughSubject<NSView, Never>()
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
