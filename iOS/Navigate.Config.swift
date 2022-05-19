import SwiftUI

extension Navigate {
    struct Config: View {
        @ObservedObject var control: Control
        
        var body: some View {
            Pop(title: "Options") {
                Toggle(isOn: $control.rotate) {
                    Image(systemName: "gyroscope")
                        .font(.system(size: 22, weight: .light))
                        .frame(width: 45)
                    Text("Allows rotation")
                        .font(.callout)
                }
                .padding()
                .padding(.top)
                
                Divider()
                    .padding(.horizontal)
            }
            .symbolRenderingMode(.hierarchical)
            .toggleStyle(SwitchToggleStyle(tint: .secondary))
        }
    }
}
