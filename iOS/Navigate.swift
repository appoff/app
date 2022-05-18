import SwiftUI

struct Navigate: View {
    let session: Session
    @StateObject var control: Control
    
    var body: some View {
        control
            .map
            .edgesIgnoringSafeArea([.top, .leading, .trailing])
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    Divider()
                        .edgesIgnoringSafeArea(.horizontal)
                        
                    HStack(spacing: 0) {
                        Action(symbol: "xmark") {
                            session.flow = .main
                        }
                        Spacer()
                        Action(symbol: "location.viewfinder", action: control.tracker)
                    }
                    .padding(.bottom, 10)
                }
            }
    }
}
