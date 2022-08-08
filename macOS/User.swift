import MapKit
import Combine

final class User: MKAnnotationView {
    private weak var halo: CAShapeLayer?
    private weak var circle: NSView!
    private var subs = Set<AnyCancellable>()
    
    override var annotation: MKAnnotation? { didSet { animate() } }
    override var reuseIdentifier: String? { "User" }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(annotation: nil, reuseIdentifier: nil)
        wantsLayer = true
        canShowCallout = false
        frame = .init(x: 0, y: 0, width: 22, height: 22)
        
        let gradient = CAGradientLayer()
        gradient.startPoint = .init(x: 0.5, y: 1)
        gradient.endPoint = .init(x: 0.5, y: 0)
        gradient.locations = [0, 1]
        gradient.frame = .init(x: 0, y: 0, width: 30, height: 30)
        gradient.colors = [CGColor(gray: 0, alpha: 1), CGColor(gray: 0, alpha: 0)]
        
        let halo = CAShapeLayer()
        halo.frame = .init(x: -7, y: -7, width: 36, height: 36)
        layer!.addSublayer(halo)
        self.halo = halo
        
        let circle = NSView()
        circle.wantsLayer = true
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer!.backgroundColor = NSColor.labelColor.cgColor
        circle.layer!.cornerRadius = 9
        addSubview(circle)
        self.circle = circle
        
        circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 18).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 18).isActive = true
    }
    
//    override func traitCollectionDidChange(_: UITraitCollection?) {
//        halo?.fillColor = UIColor.secondaryLabel.cgColor
//        heading?.fillColor = UIColor.secondaryLabel.cgColor
//        reanimate()
//    }
    
    private func animate() {
        if halo?.animation(forKey: "halo") == nil {
            let group = CAAnimationGroup()
            group.repeatCount = .infinity
            group.duration = 3.5
            group.animations = [{
                $0.fromValue = CGPath(ellipseIn: .init(x: 0, y: 0, width: 36, height: 36), transform: nil)
                $0.toValue = CGPath(ellipseIn: .init(x: 10, y: 10, width: 16, height: 16), transform: nil)
                $0.duration = 3
                return $0
            } (CABasicAnimation(keyPath: "path")), {
                $0.fromValue = NSColor.clear.cgColor
                $0.toValue = halo?.fillColor
                $0.duration = 1.5
                return $0
            } (CABasicAnimation(keyPath: "fillColor"))]
            halo?.add(group, forKey: "halo")
        }
    }
}
