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
                        Action(size: 18, symbol: "xmark") {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                session.flow = .main
                            }
                        }
                        
                        Action(symbol: "line.3.horizontal") {
                            control.points = true
                        }
                        .sheet(isPresented: $control.points) {
                            Sheet(rootView: Points(control: control))
                        }
                        
                        Action(symbol: "slider.vertical.3") {
                            control.config = true
                        }
                        .sheet(isPresented: $control.config) {
                            Sheet(rootView: Config(control: control))
                        }
                        
                        Action(symbol: "location.viewfinder", action: control.tracker)
                    }
                    .padding(.bottom, 12)
                }
            }
            .preferredColorScheme(control.color)
    }
}
