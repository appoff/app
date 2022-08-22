import AppKit
import Coffee
import Combine
import Offline

final class Premium: NSView {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, header: Header, move: PassthroughSubject<Void, Never>) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let share = Control.Prominent(title: "Share")
        share.toolTip = "Share map"
        share
            .click
            .sink {
                move.send()
                session.flow.value = .share(header)
            }
            .store(in: &subs)
        
        let offload = Control.Prominent(title: "Offload")
        offload.toolTip = "Offload map"
        offload
            .click
            .sink {
                move.send()
                session.flow.value = .offload(header)
            }
            .store(in: &subs)
        
        [share, offload]
            .forEach {
                $0.color = .windowBackgroundColor
                $0.text.textColor = .labelColor
                addSubview($0)
                
                $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
                $0.widthAnchor.constraint(equalToConstant: 120).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 34).isActive = true
            }
        
        widthAnchor.constraint(equalToConstant: 300).isActive = true
        bottomAnchor.constraint(equalTo: offload.bottomAnchor, constant: 20).isActive = true
        
        share.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        offload.topAnchor.constraint(equalTo: share.bottomAnchor, constant: 10).isActive = true
    }
    
    override var allowsVibrancy: Bool {
        true
    }
}
