import MapKit
import Combine

final class User: MKAnnotationView {
    private weak var halo: CAShapeLayer?
    private weak var heading: CAShapeLayer?
    private weak var gradient: CAGradientLayer?
    private weak var circle: UIView!
    private var subs = Set<AnyCancellable>()
    
    override var annotation: MKAnnotation? { didSet { animate() } }
    override var reuseIdentifier: String? { "User" }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(annotation: nil, reuseIdentifier: nil)
        canShowCallout = false
        frame = .init(x: 0, y: 0, width: 22, height: 22)
        
        let gradient = CAGradientLayer()
        gradient.startPoint = .init(x: 0.5, y: 1)
        gradient.endPoint = .init(x: 0.5, y: 0)
        gradient.locations = [0, 1]
        gradient.frame = .init(x: 0, y: 0, width: 30, height: 50)
        self.gradient = gradient
        
        let heading = CAShapeLayer()
        heading.frame = .init(x: -4, y: -14, width: 30, height: 50)
        heading.anchorPoint = .init(x: 0.5, y: 1)
        heading.path = { path in
            path.move(to: .zero)
            path.addLine(to: .init(x: 30, y: 0))
            path.addLine(to: .init(x: 20, y: 50))
            path.addLine(to: .init(x: 10, y: 50))
            path.closeSubpath()
            return path
        } (CGMutablePath())
        heading.mask = gradient
        layer.addSublayer(heading)
        self.heading = heading
        
        let halo = CAShapeLayer()
        halo.frame = .init(x: -7, y: -7, width: 36, height: 36)
        layer.addSublayer(halo)
        self.halo = halo
        
        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.isUserInteractionEnabled = false
        circle.backgroundColor = .label
        circle.layer.cornerRadius = 9
        addSubview(circle)
        self.circle = circle
        
        circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 18).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        NotificationCenter
            .default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.reanimate()
            }
            .store(in: &subs)
    }
    
    func orientation(angle: Double) {
        heading?.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
    }
    
    override func traitCollectionDidChange(_: UITraitCollection?) {
        halo?.fillColor = UIColor.secondaryLabel.cgColor
        heading?.fillColor = UIColor.label.withAlphaComponent(0.6).cgColor
        gradient?.colors = [heading?.fillColor ?? UIColor.clear.cgColor, UIColor.clear.cgColor]
        reanimate()
    }
    
    private func reanimate() {
        halo?.removeAnimation(forKey: "halo")
        animate()
    }
    
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
                $0.fromValue = UIColor.clear.cgColor
                $0.toValue = halo?.fillColor
                $0.duration = 1.5
                return $0
            } (CABasicAnimation(keyPath: "fillColor"))]
            halo?.add(group, forKey: "halo")
        }
    }
}
