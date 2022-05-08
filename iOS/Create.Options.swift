import SwiftUI
import Offline

extension Create {
    struct Options: View {
        @State private var map = Settings.Map.standard
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                            .padding([.trailing, .top], 15)
                            .contentShape(Rectangle())
                    }
                }
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
