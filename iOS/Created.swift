import SwiftUI
import Offline

struct Created: View {
    let session: Session
    let header: Header
    @AppStorage("cloud") private var cloud = false
    
    var body: some View {
        VStack {
            Spacer()
            Image("Created")
                .foregroundColor(.primary)
                .padding(.top, 40)
            Text("Ready")
                .font(.title2.weight(.regular))
            Text(header.title)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: 280)
            
            Spacer()
            
            if cloud {
                Premium(session: session, header: header)
            } else {
                Upgrade()
            }
            
            Spacer()
            
            Button {
                withAnimation(.easeOut(duration: 0.3)) {
                    session.flow = .main
                }
            } label: {
                Text("Continue")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)
                    .padding()
                    .contentShape(Rectangle())
            }
            Spacer()
        }
        .onAppear {
            if Defaults.rate {
                UIApplication.shared.review()
            }
        }
    }
}
