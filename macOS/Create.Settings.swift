import AppKit
import Coffee
import Combine
import Offline

extension Create {
    final class Settings: NSView {
        private weak var type: CurrentValueSubject<Offline.Settings.Map, Never>!
        private let session: Session
        
        required init?(coder: NSCoder) { nil }
        init(session: Session,
             type: CurrentValueSubject<Offline.Settings.Map, Never>) {
            
            self.session = session
            self.type = type
            super.init(frame: .init(x: 0, y: 0, width: 340, height: 300))
            
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
                action: #selector(update))
            typeSegmented.translatesAutoresizingMaskIntoConstraints = false
            typeSegmented.controlSize = .large
            typeSegmented.selectedSegment = .init(type.value.rawValue)
            
            let firstDivider = Separator()
            
            let travelTitle = Text(vibrancy: true)
            travelTitle.stringValue = "Travel mode"
            
            let secondDivider = Separator()
            
            let pointsTitle = Text(vibrancy: true)
            pointsTitle.stringValue = "Points of interest"

            [typeSegmented]
                .forEach {
                    addSubview($0)
                    
                    $0.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
                    $0.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
                }
            
            [typeTitle, travelTitle, pointsTitle]
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
            
            typeTitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
            typeSegmented.topAnchor.constraint(equalTo: typeTitle.bottomAnchor, constant: 5).isActive = true
            firstDivider.topAnchor.constraint(equalTo: typeSegmented.bottomAnchor, constant: 10).isActive = true
            travelTitle.topAnchor.constraint(equalTo: firstDivider.bottomAnchor, constant: 20).isActive = true
        }
        
        @objc private func update(_ segmented: NSSegmentedControl) {
            guard .init(type.value.rawValue) != segmented.selectedSegment else { return }
            type.value = .init(rawValue: .init(segmented.selectedSegment))!
        }
    }
}
/*
 import SwiftUI
 import Offline

 extension Create {
     struct Settings: View {
         @ObservedObject var builder: Builder
         
         var body: some View {
             Pop(title: "Settings") {
                 Text("Type")
                     .font(.callout)
                     .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                     .padding(.leading)
                     .padding(.bottom, 10)
                 Picker("Type", selection: $builder.type) {
                     ForEach(Offline.Settings.Map.allCases, id: \.self) {
                         Text(verbatim: "\($0)".capitalized)
                             .tag($0)
                     }
                 }
                 .pickerStyle(.segmented)
                 .padding([.leading, .trailing, .bottom])
                 
                 Divider()
                     .padding(.horizontal)
                 
                 Text("Travel mode")
                     .font(.callout)
                     .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                     .padding([.leading, .top])
                     .padding(.bottom, 10)
                 Picker("Travel model", selection: $builder.directions) {
                     Label("Walking", systemImage: "figure.walk")
                         .tag(Offline.Settings.Directions.walking)
                     Label("Driving", systemImage: "car")
                         .tag(Offline.Settings.Directions.driving)
                 }
                 .symbolRenderingMode(.hierarchical)
                 .pickerStyle(.segmented)
                 .labelStyle(.iconOnly)
                 .padding([.leading, .trailing, .bottom])
                 
                 Divider()
                     .padding(.horizontal)
                 
                 Toggle(isOn: $builder.interest) {
                     Image(systemName: "building.2")
                         .font(.system(size: 22, weight: .light))
                         .frame(width: 45)
                         .frame(minHeight: 36)
                     Text("Points of interest")
                         .font(.callout)
                 }
                 .font(.callout)
                 .padding()
             }
             .symbolRenderingMode(.hierarchical)
             .toggleStyle(SwitchToggleStyle(tint: .secondary))
         }
     }
 }

 */
