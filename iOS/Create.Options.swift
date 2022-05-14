import SwiftUI
import Offline

extension Create {
    struct Options: View {
        @ObservedObject var builder: Builder
        
        var body: some View {
            Pop {
                Text("Map type")
                    .font(.callout)
                    .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                    .padding(.leading)
                    .padding(.bottom, 10)
                Picker("Map type", selection: $builder.type) {
                    ForEach(Settings.Map.allCases, id: \.self) {
                        Text(verbatim: "\($0)".capitalized)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.leading, .trailing, .bottom])
                
                Divider()
                    .padding(.horizontal)
                
                Toggle(isOn: $builder.interest) {
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
                
                Toggle(isOn: $builder.rotate) {
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
        }
    }
}
