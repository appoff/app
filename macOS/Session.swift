import Combine
import StoreKit
import Offline

final class Session {
    let loading = CurrentValueSubject<_, Never>(true)
    let filtered = CurrentValueSubject<[Project], Never>([])
    let search = CurrentValueSubject<_, Never>("")
    let flow = CurrentValueSubject<_, Never>(Flow.main)
    let save = PassthroughSubject<Void, Never>()
    let cancel = PassthroughSubject<Project?, Never>()
    let trash = PassthroughSubject<Void, Never>()
    let ready = CurrentValueSubject<_, Never>(false)
    let follow = PassthroughSubject<Void, Never>()
    let current = PassthroughSubject<Void, Never>()
    let find = PassthroughSubject<Void, Never>()
    let settings = PassthroughSubject<NSView, Never>()
    let options = PassthroughSubject<NSView, Never>()
    let help = PassthroughSubject<NSView, Never>()
    let share = PassthroughSubject<Void, Never>()
    let offload = PassthroughSubject<Void, Never>()
    let selected = CurrentValueSubject<Project?, Never>(nil)
    let premium: CurrentValueSubject<Bool, Never>
    let local = Local()
    private var reviewed = false
    private var subs = Set<AnyCancellable>()
    
    init() {
        premium = .init(UserDefaults.standard.value(forKey: "cloud") as? Bool ?? false)
        
        cloud
            .combineLatest(search) {
                $0.projects.filtered(search: $1)
            }
            .sink { [weak self] in
                self?.filtered.value = $0
            }
            .store(in: &subs)
        
        store
            .purchased
            .sink { [weak self] in
                self?.premium.value = true
                ((NSApp as! App).anyWindow() ?? Purchased())
                    .makeKeyAndOrderFront(nil)
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
