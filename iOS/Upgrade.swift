import SwiftUI

struct Upgrade: View {
    @State private var about = false
    
    var body: some View {
        VStack {
            Text("Cloud")
                .font(.title2.weight(.medium))
            Text("You are 1 step\nfrom Offline Cloud.")
                .multilineTextAlignment(.center)
                .font(.callout.weight(.regular))
                .fixedSize(horizontal: false, vertical: true)
            Button {
                about = true
            } label: {
                Text("Get Offline Cloud")
                    .font(.callout.weight(.medium))
                    .frame(minWidth: 200)
                    .frame(minHeight: 28)
            }
            .buttonStyle(.borderedProminent)
            .tint(.init(.secondarySystemBackground))
            .foregroundColor(.primary)
            
            Text("1 time purchase of 4,99 €")
                .multilineTextAlignment(.center)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 240)
        }
//        .sheet(isPresented: $about, content: About.init)
    }
}
