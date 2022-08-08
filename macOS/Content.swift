import AppKit
import Coffee
import Combine

final class Content: NSVisualEffectView {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        state = .active
        material = .sidebar
        
        session
            .flow
            .sink {
                switch $0 {
                default:
                    break
                }
            }
            .store(in: &subs)
    }
}
