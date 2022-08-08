import AppKit
import Coffee
import Combine

final class Topbar: NSView {
    private var subs = Set<AnyCancellable>()
    private let session: Session
    
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        self.session = session
        super.init(frame: .zero)
        
        let create = Button(symbol: "plus")
        create.toolTip = "New map"
        create
            .click
            .sink {
                session.flow.value = .create
            }
            .store(in: &subs)
        addSubview(create)
        
        let scan = Button(symbol: "square.and.arrow.down")
        scan.toolTip = "Import map"
        scan
            .click
            .sink {
                session.flow.value = .scan
            }
            .store(in: &subs)
        addSubview(scan)
        
        create.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        scan.leftAnchor.constraint(equalTo: create.rightAnchor, constant: 10).isActive = true
        
        [create, scan]
            .forEach {
                $0.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
                $0.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            }
        
        session
            .flow
            .sink {
                switch $0 {
                case .main:
                    create.state = .on
                    scan.state = .on
                default:
                    create.state = .off
                    scan.state = .off
                }
            }
            .store(in: &subs)
    }
}
