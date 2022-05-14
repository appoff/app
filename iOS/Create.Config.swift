import SwiftUI
import Offline

extension Create {
    struct Config: View {
        @ObservedObject var builder: Builder
        
        var body: some View {
            Pop {
                Text("Appearance")
                    .font(.callout)
                    .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                    .padding(.leading)
                    .padding(.bottom, 10)
                Picker("Appearance", selection: $builder.scheme) {
                    Label("Auto", systemImage: "circle.righthalf.filled")
                        .tag(Settings.Scheme.auto)
                    Label("Light", systemImage: "sun.max")
                        .tag(Settings.Scheme.light)
                    Label("Dark", systemImage: "moon.stars")
                        .tag(Settings.Scheme.dark)
                }
                .symbolRenderingMode(.hierarchical)
                .pickerStyle(.segmented)
                .labelStyle(.iconOnly)
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
                        .tag(Settings.Directions.walking)
                    Label("Driving", systemImage: "car")
                        .tag(Settings.Directions.driving)
                }
                .symbolRenderingMode(.hierarchical)
                .pickerStyle(.segmented)
                .labelStyle(.iconOnly)
                .padding([.leading, .trailing, .bottom])
            }
        }
    }
}
