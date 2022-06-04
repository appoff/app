import SwiftUI

struct Empty: View {
    var body: some View {
        VStack {
            Text("Empty maps")
            Text("When you create a map on Offline for iPhone, iPad or Mac it will appear here.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .font(.footnote)
                .padding(.horizontal)
        }
    }
}
