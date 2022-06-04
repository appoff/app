import SwiftUI

struct Loading: View {
    var body: some View {
        Image("Logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.primary)
            .frame(width: 80)
    }
}
