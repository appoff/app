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
        
        var view: NSView?
        
        session
            .flow
            .sink {
                view?.removeFromSuperview()
                
                switch $0 {
                case .create:
                    view = Create(session: session)
                    self.material = .sidebar
                    self.window?.isMovableByWindowBackground = false
                case let .loading(factory):
                    view = Loading(session: session, factory: factory)
                    self.material = .hudWindow
                    self.window?.isMovableByWindowBackground = true
                case let .created(header):
                    view = Created(session: session, header: header)
                    self.material = .menu
                    self.window?.isMovableByWindowBackground = true
                case let .share(header):
                    view = Share(session: session, header: header)
                    self.material = .hudWindow
                    self.window?.isMovableByWindowBackground = true
                case let .shared(header, image):
                    view = Shared(session: session, header: header, image: image)
                    self.material = .sidebar
                    self.window?.isMovableByWindowBackground = true
                case let .deleted(header):
                    view = Deleted(session: session, header: header)
                    self.material = .sidebar
                    self.window?.isMovableByWindowBackground = true
                default:
                    view = Main(session: session)
                    self.material = .hudWindow
                    self.window?.isMovableByWindowBackground = true
                }
                
                self.addSubview(view!)
                
                view!.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                view!.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                view!.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
                view!.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            }
            .store(in: &subs)
    }
}
