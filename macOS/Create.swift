import AppKit
import Coffee

final class Create: NSView {
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let divider = Separator()
        addSubview(divider)
        
        let builder = Builder(session: session)
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
}
