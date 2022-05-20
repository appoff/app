import SwiftUI
import Offline

extension Create {
    struct Config: View {
        @ObservedObject var builder: Builder
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            Pop(title: "Options") {
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
                
                Button {
                    builder.current()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 22, weight: .light))
                            .frame(width: 45)
                            .frame(minHeight: 36)
                        Text("My location")
                            .font(.callout)
                        Spacer()
                    }
                    .padding()
                    .contentShape(Rectangle())
                    .foregroundColor(.primary)
                }
                
                Divider()
                    .padding(.horizontal)
                
                Toggle(isOn: $builder.rotate) {
                    Image(systemName: "gyroscope")
                        .font(.system(size: 22, weight: .light))
                        .frame(width: 45)
                        .frame(minHeight: 36)
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
