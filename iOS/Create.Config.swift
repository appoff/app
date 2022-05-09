import SwiftUI
import Offline

extension Create {
    struct Config: View {
        @State private var scheme = Settings.Scheme.auto
        
        var body: some View {
            Pop {
                Text("Appearance")
                    .font(.callout)
                    .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                    .padding(.leading)
                    .padding(.bottom, 10)
                Picker("Appearance", selection: $scheme) {
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
            }
            .onReceive(cloud) {
                scheme = $0.settings.scheme
            }
            .onChange(of: scheme) { value in
                Task {
                    await cloud.update(scheme: value)
                }
            }
        }
    }
}
