import AppKit
import Coffee
import Combine
import Offline

extension Create {
    final class Settings: NSView {
        private weak var type: CurrentValueSubject<Offline.Settings.Map, Never>!
        private weak var directions: CurrentValueSubject<Offline.Settings.Directions, Never>!
        private weak var interest: CurrentValueSubject<Bool, Never>!
        
        required init?(coder: NSCoder) { nil }
        init(type: CurrentValueSubject<Offline.Settings.Map, Never>,
             directions: CurrentValueSubject<Offline.Settings.Directions, Never>,
             interest: CurrentValueSubject<Bool, Never>) {
            
            self.type = type
            self.directions = directions
            self.interest = interest
            super.init(frame: .init(x: 0, y: 0, width: 340, height: 340))
            
            let title = Text(vibrancy: true)
            title.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .title2).pointSize, weight: .medium)
            title.stringValue = "Settings"
            addSubview(title)
            
            let typeTitle = Text(vibrancy: true)
            typeTitle.stringValue = "Type"
            
            let typeSegmented = NSSegmentedControl(
                labels:
                    [Offline.Settings.Map.standard,
                     .satellite,
                     .hybrid,
                     .emphasis]
                    .map {
                        "\($0)".capitalized
                    },
                trackingMode: .selectOne,
                target: self,
                action: #selector(updateType))
            typeSegmented.translatesAutoresizingMaskIntoConstraints = false
            typeSegmented.controlSize = .large
            typeSegmented.selectedSegment = .init(type.value.rawValue)
            
            let firstDivider = Separator()
            
            let directionsTitle = Text(vibrancy: true)
            directionsTitle.stringValue = "Travel mode"
            
            let directionsSegmented = NSSegmentedControl(
                images: ["figure.walk",
                         "car"]
                    .compactMap {
                        .init(systemSymbolName: $0, accessibilityDescription: nil)
                    },
                trackingMode: .selectOne,
                target: self,
                action: #selector(updateDirections))
            directionsSegmented.translatesAutoresizingMaskIntoConstraints = false
            directionsSegmented.controlSize = .large
            directionsSegmented.selectedSegment = .init(directions.value.rawValue)
            
            let secondDivider = Separator()
            
            let pointsTitle = Text(vibrancy: true)
            pointsTitle.stringValue = "Points of interest"
            
            let pointsIcon = NSImageView(image: .init(systemSymbolName: "building.2", accessibilityDescription: nil) ?? .init())
            pointsIcon.translatesAutoresizingMaskIntoConstraints = false
            pointsIcon.symbolConfiguration = .init(pointSize: 20, weight: .regular)
                .applying(.init(hierarchicalColor: .secondaryLabelColor))
            addSubview(pointsIcon)
            
            let pointsSwitch = NSSwitch()
            pointsSwitch.target = self
            pointsSwitch.action = #selector(updatePoints)
            pointsSwitch.translatesAutoresizingMaskIntoConstraints = false
            pointsSwitch.controlSize = .large
            pointsSwitch.state = interest.value ? .on : .off
            addSubview(pointsSwitch)

            [typeSegmented, directionsSegmented]
                .forEach {
                    addSubview($0)
                    
                    $0.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
                    $0.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
                }
            
            [typeTitle, directionsTitle, pointsTitle]
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
            
            title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            title.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
            
            typeTitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 25).isActive = true
            typeSegmented.topAnchor.constraint(equalTo: typeTitle.bottomAnchor, constant: 5).isActive = true
            firstDivider.topAnchor.constraint(equalTo: typeSegmented.bottomAnchor, constant: 20).isActive = true
            directionsTitle.topAnchor.constraint(equalTo: firstDivider.bottomAnchor, constant: 20).isActive = true
            directionsSegmented.topAnchor.constraint(equalTo: directionsTitle.bottomAnchor, constant: 5).isActive = true
            secondDivider.topAnchor.constraint(equalTo: directionsSegmented.bottomAnchor, constant: 20).isActive = true
            pointsTitle.topAnchor.constraint(equalTo: secondDivider.bottomAnchor, constant: 25).isActive = true
            pointsIcon.centerYAnchor.constraint(equalTo: pointsTitle.centerYAnchor).isActive = true
            pointsIcon.leftAnchor.constraint(equalTo: pointsTitle.rightAnchor, constant: 10).isActive = true
            pointsSwitch.centerYAnchor.constraint(equalTo: pointsTitle.centerYAnchor).isActive = true
            pointsSwitch.rightAnchor.constraint(equalTo: rightAnchor, constant: -38).isActive = true
        }
        
        @objc private func updateType(_ segmented: NSSegmentedControl) {
            guard .init(type.value.rawValue) != segmented.selectedSegment else { return }
            type.value = .init(rawValue: .init(segmented.selectedSegment))!
        }
        
        @objc private func updateDirections(_ segmented: NSSegmentedControl) {
            guard .init(directions.value.rawValue) != segmented.selectedSegment else { return }
            directions.value = .init(rawValue: .init(segmented.selectedSegment))!
        }
        
        @objc private func updatePoints(_ control: NSSwitch) {
            guard
                (interest.value && control.state == .off)
                    || (!interest.value && control.state == .on)
            else { return }
            interest.value = control.state == .on
        }
    }
}
