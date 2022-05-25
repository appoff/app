import SwiftUI
import StoreKit

struct Upgrade: View {
    @State private var about = false
    @State private var product: Product?
    
    var body: some View {
        VStack {
            Text("You are 1 step\nfrom Offline Cloud.")
                .multilineTextAlignment(.center)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                about = true
            } label: {
                Text("Get Offline Cloud")
                    .font(.footnote.weight(.bold))
                    .padding(.horizontal)
                    .frame(minHeight: 28)
            }
            .buttonStyle(.borderedProminent)
            .tint(.init(.secondarySystemBackground))
            .foregroundColor(.primary)
            
            if let product = product {
                Text("1 time purchase of " + product.displayPrice)
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 240)
            }
        }
        .task {
            product = await store.load(item: .cloud)
        }
//        .sheet(isPresented: $about, content: About.init)
    }
}
