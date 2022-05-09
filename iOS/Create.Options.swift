import SwiftUI
import Offline

extension Create {
    struct Options: View {
        @State private var map = Settings.Map.standard
        
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
                
                Spacer()
            }
            .onReceive(cloud) {
                map = $0.settings.map
            }
            .onChange(of: map) { value in
                Task {
                    await cloud.update(map: value)
                }
            }
        }
    }
}
