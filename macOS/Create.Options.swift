import AppKit
import Coffee
import Combine
import Offline

extension Create {
    final class Options: NSView {
        private weak var scheme: CurrentValueSubject<Offline.Settings.Scheme, Never>!
        private weak var rotate: CurrentValueSubject<Bool, Never>!
        private var subs = Set<AnyCancellable>()
        
        required init?(coder: NSCoder) { nil }
        init(session: Session,
             scheme: CurrentValueSubject<Offline.Settings.Scheme, Never>,
             rotate: CurrentValueSubject<Bool, Never>) {
            
            self.scheme = scheme
            self.rotate = rotate
            super.init(frame: .init(x: 0, y: 0, width: 280, height: 320))
            
            let title = Text(vibrancy: true)
            title.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .title2).pointSize, weight: .medium)
            title.stringValue = "Options"
            addSubview(title)
            
            let schemeTitle = Text(vibrancy: true)
            schemeTitle.stringValue = "Appearance"
            
            let schemeSegmented = NSSegmentedControl(
                images: ["circle.righthalf.filled",
                         "sun.max",
                         "moon.stars"]
                    .compactMap {
                        .init(systemSymbolName: $0, accessibilityDescription: nil)
                    },
                trackingMode: .selectOne,
                target: self,
                action: #selector(updateScheme))
            schemeSegmented.translatesAutoresizingMaskIntoConstraints = false
            schemeSegmented.controlSize = .large
            schemeSegmented.selectedSegment = .init(scheme.value.rawValue)
            
            let firstDivider = Separator()
            
            let rotateTitle = Text(vibrancy: true)
            rotateTitle.stringValue = "Rotation"
            
            let rotateIcon = NSImageView(image: .init(systemSymbolName: "gyroscope", accessibilityDescription: nil) ?? .init())
            rotateIcon.translatesAutoresizingMaskIntoConstraints = false
            rotateIcon.symbolConfiguration = .init(pointSize: 20, weight: .regular)
                .applying(.init(hierarchicalColor: .secondaryLabelColor))
            addSubview(rotateIcon)
            
            let rotateSwitch = NSSwitch()
            rotateSwitch.target = self
            rotateSwitch.action = #selector(updateRotate)
            rotateSwitch.translatesAutoresizingMaskIntoConstraints = false
            rotateSwitch.controlSize = .large
            rotateSwitch.state = rotate.value ? .on : .off
            addSubview(rotateSwitch)
            
            let secondDivider = Separator()
            
            let location = Control.Prominent(title: "Mark my location")
            location.text.textColor = .windowBackgroundColor
            location
                .click
                .sink { [weak self] in
                    guard let self = self else { return }
                    session.current.send()
                    NSPopover.close(content: self)
                }
                .store(in: &subs)
            
            [schemeSegmented, location]
                .forEach {
                    addSubview($0)
                    
                    $0.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
                    $0.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
                }
            
            [schemeTitle, rotateTitle]
                .forEach {
                    addSubview($0)
                    
                    $0.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
                    $0.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
                }
            
            [firstDivider, secondDivider]
                .forEach {
                    addSubview($0)
                    
                    $0.heightAnchor.constraint(equalToConstant: 1).isActive = true
                    $0.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
                    $0.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
                }
            
            title.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
            title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            
            schemeTitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 25).isActive = true
            schemeSegmented.topAnchor.constraint(equalTo: schemeTitle.bottomAnchor, constant: 5).isActive = true
            firstDivider.topAnchor.constraint(equalTo: schemeSegmented.bottomAnchor, constant: 20).isActive = true
            rotateTitle.topAnchor.constraint(equalTo: firstDivider.bottomAnchor, constant: 25).isActive = true
            rotateIcon.centerYAnchor.constraint(equalTo: rotateTitle.centerYAnchor).isActive = true
            rotateIcon.leftAnchor.constraint(equalTo: rotateTitle.rightAnchor, constant: 10).isActive = true
            rotateSwitch.centerYAnchor.constraint(equalTo: rotateTitle.centerYAnchor).isActive = true
            rotateSwitch.rightAnchor.constraint(equalTo: rightAnchor, constant: -38).isActive = true
            secondDivider.topAnchor.constraint(equalTo: rotateTitle.bottomAnchor, constant: 25).isActive = true
            location.topAnchor.constraint(equalTo: secondDivider.bottomAnchor, constant: 25).isActive = true
            location.widthAnchor.constraint(equalToConstant: 200).isActive = true
        }
        
        @objc private func updateScheme(_ segmented: NSSegmentedControl) {
            guard .init(scheme.value.rawValue) != segmented.selectedSegment else { return }
            scheme.value = .init(rawValue: .init(segmented.selectedSegment))!
        }
        
        @objc private func updateRotate(_ control: NSSwitch) {
            guard
                (rotate.value && control.state == .off)
                    || (!rotate.value && control.state == .on)
            else { return }
            rotate.value = control.state == .on
        }
    }
}
