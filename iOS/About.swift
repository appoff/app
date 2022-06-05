import SwiftUI

struct About: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28, weight: .light))
                        .frame(width: 36, height: 36)
                        .padding(.trailing, 12)
                        .contentShape(Rectangle())
                }
            }
            .padding(.top, 12)
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
                .padding(.top)
            Text("Offline")
                .font(.title.weight(.regular))
                .foregroundColor(.primary)
            Spacer()
            Button {
                UIApplication.shared.share(URL(string: "https://apps.apple.com/us/app/offline/id1622402009?platform=iphone")!)
            } label: {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
                    .foregroundColor(.primary)
                    .font(.system(size: 40, weight: .regular))
                    .contentShape(Rectangle())
            }
            
            Spacer()
            Text(verbatim: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "")
                .font(.body.monospacedDigit())
                .foregroundStyle(.secondary)
            HStack(spacing: 0) {
                Text("From Berlin with ")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
                Image(systemName: "heart.fill")
                    .font(.footnote)
                    .foregroundStyle(.pink)
            }
            .padding(.bottom)
        }
    }
}
