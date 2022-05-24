import MapKit
import Combine

final class User: MKAnnotationView {
    private(set) weak var heading: UIImageView?
    private weak var halo: CAShapeLayer?
    private weak var circle: UIView!
    private var subs = Set<AnyCancellable>()
    
    override var annotation: MKAnnotation? { didSet { animate() } }
    override var reuseIdentifier: String? { "User" }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(annotation: nil, reuseIdentifier: nil)
        canShowCallout = false
        frame = .init(x: 0, y: 0, width: 22, height: 22)
        
        let halo = CAShapeLayer()
        halo.frame = .init(x: -7, y: -7, width: 36, height: 36)
        layer.insertSublayer(halo, below: nil)
        self.halo = halo
        
        let heading = UIImageView(image: UIImage(named: "heading"))
        heading.translatesAutoresizingMaskIntoConstraints = false
        heading.contentMode = .center
        heading.clipsToBounds = true
        addSubview(heading)
        self.heading = heading
        
        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.isUserInteractionEnabled = false
        circle.backgroundColor = .label
        circle.layer.cornerRadius = 9
        addSubview(circle)
        self.circle = circle
        
        heading.widthAnchor.constraint(equalToConstant: 35).isActive = true
        heading.heightAnchor.constraint(equalToConstant: 110).isActive = true
        heading.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        heading.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
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
    
    override func traitCollectionDidChange(_: UITraitCollection?) {
        halo?.fillColor = UIColor.secondaryLabel.cgColor
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
