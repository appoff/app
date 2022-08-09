import AppKit
import Coffee

final class Create: NSView {
    private var pressed: TimeInterval?
    private let builder: Builder
    
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        let builder = Builder(session: session)
        self.builder = builder
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let divider = Separator()
        addSubview(divider)
        
        addSubview(builder)
        
        divider.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        divider.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        divider.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        builder.topAnchor.constraint(equalTo: divider.bottomAnchor).isActive = true
        builder.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        builder.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        builder.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    override func mouseDown(with: NSEvent) {
        super.mouseDown(with: with)
        
        if with.clickCount == 1 {
            pressed = with.timestamp
        }
    }
    
    override func mouseDragged(with: NSEvent) {
        super.mouseDragged(with: with)
        pressed = with.timestamp
    }
    
    override func mouseUp(with: NSEvent) {
        guard
            with.clickCount == 1,
            let pressed = pressed,
            with.timestamp - pressed > 1
        else {
            self.pressed = nil
            super.mouseUp(with: with)
            return
        }
        self.pressed = nil
        builder.pressed(location: with.locationInWindow)
    }
}
