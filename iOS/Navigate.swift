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
                        Action(size: 16, symbol: "xmark") {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                session.flow = .main
                            }
                        }
                        
                        Action(symbol: "line.3.horizontal") {
                            session.flow = .main
                        }
                        
                        Action(symbol: "slider.vertical.3") {
                            session.flow = .main
                        }
                        
                        Action(symbol: "location.viewfinder", action: control.tracker)
                    }
                    .padding(.bottom, 10)
                }
            }
    }
}
