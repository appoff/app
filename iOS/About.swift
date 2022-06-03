import SwiftUI

struct About: View {
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 160)
                .padding(.vertical)
            Text("Offline")
                .font(.largeTitle.weight(.medium))
                .foregroundColor(.primary)
            Spacer()
            Link(destination: .init(string: "https://apps.apple.com/us/app/offline/id1622402009?platform=iphone")!) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.tertiary)
                    .foregroundColor(.primary)
                    .font(.system(size: 60, weight: .ultraLight))
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
