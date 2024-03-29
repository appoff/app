import SwiftUI

struct Purchased: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "cloud")
                .font(.system(size: 80, weight: .ultraLight))
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.accentColor)
                .padding(.bottom, 20)
            
            Text("Offline Cloud")
                .font(.title.weight(.bold))
            Text("Purchase successful!")
                .font(.title3.weight(.regular))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
                .padding(.vertical, 5)
            
            Button {
                dismiss()
            } label: {
                Text("OK")
                    .font(.body.weight(.bold))
                    .padding(.horizontal)
                    .frame(minWidth: 140, minHeight: 30)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .foregroundColor(.white)
            .padding(.top, 20)
        }
        .frame(maxWidth: .greatestFiniteMagnitude)
    }
}
