import SwiftUI

struct Empty: View {
    var body: some View {
        VStack {
            Text("Empty maps")
            Text("""
Once you create maps they appear here.

Create them on Offline for iPhone, iPad and Mac.
""")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .font(.footnote)
                .padding(.horizontal)
        }
        .ignoresSafeArea(edges: .all)
    }
}
