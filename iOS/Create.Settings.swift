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
