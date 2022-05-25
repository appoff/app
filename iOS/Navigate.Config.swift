import SwiftUI

extension Navigate {
    struct Config: View {
        @ObservedObject var control: Control
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            Pop(title: "Options") {
                Toggle(isOn: $control.rotate) {
                    Image(systemName: "gyroscope")
                        .font(.system(size: 22, weight: .light))
                        .frame(width: 45)
                        .frame(minHeight: 36)
                    Text("Rotation")
                        .font(.callout)
                }
                .padding()
                .padding(.top)
                
                Divider()
                    .padding(.horizontal)
                
                Toggle(isOn: $control.directions) {
                    Image(systemName: "arrow.triangle.turn.up.right.circle")
                        .font(.system(size: 22, weight: .light))
                        .frame(width: 45)
                        .frame(minHeight: 36)
                    Text("Directions")
                        .font(.callout)
                }
                .onChange(of: control.directions) { _ in
                    dismiss()
                }
                .padding()
                
                Divider()
                    .padding(.horizontal)
            }
            .symbolRenderingMode(.hierarchical)
            .toggleStyle(SwitchToggleStyle(tint: .secondary))
        }
    }
}
