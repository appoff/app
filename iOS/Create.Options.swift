import SwiftUI
import Offline

extension Create {
    struct Options: View {
        @State private var map = Settings.Map.standard
        @State private var interest = true
        @State private var rotate = false
        
        var body: some View {
            Pop {
                Text("Map type")
                    .font(.callout)
                    .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                    .padding(.leading)
                    .padding(.bottom, 10)
                Picker("Map type", selection: $map) {
                    ForEach(Settings.Map.allCases, id: \.self) {
                        Text(verbatim: "\($0)".capitalized)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.leading, .trailing, .bottom])
                
                Divider()
                    .padding(.horizontal)
                
                Toggle(isOn: $interest) {
                    Image(systemName: "theatermasks")
                        .font(.system(size: 22, weight: .light))
                        .frame(width: 45)
                    Text("Points of interest")
                        .font(.callout)
                }
                .font(.callout)
                .padding()
                
                Divider()
                    .padding(.horizontal)
                
                Toggle(isOn: $rotate) {
                    Image(systemName: "gyroscope")
                        .font(.system(size: 22, weight: .light))
                        .frame(width: 45)
                    Text("Allows rotation")
                        .font(.callout)
                }
                .padding()
            }
            .symbolRenderingMode(.hierarchical)
            .toggleStyle(SwitchToggleStyle(tint: .secondary))
            .onReceive(cloud) {
                map = $0.settings.map
                interest = $0.settings.interest
                rotate = $0.settings.rotate
            }
            .onChange(of: map) { value in
                Task {
                    await cloud.update(map: value)
                }
            }
            .onChange(of: interest) { value in
                Task {
                    await cloud.update(interest: value)
                }
            }
            .onChange(of: rotate) { value in
                Task {
                    await cloud.update(rotate: value)
                }
            }
        }
    }
}
