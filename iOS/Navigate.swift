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
                        
                    HStack(spacing: 22) {
                        Action(size: 18, symbol: "xmark") {
                            withAnimation(.easeIn(duration: 0.4)) {
                                session.flow = .main
                            }
                        }
                        
                        Action(symbol: "slider.horizontal.3") {
                            control.map.follow = false
                            control.options = true
                        }
                        .sheet(isPresented: $control.options) {
                            Sheet(rootView: Options(control: control))
                        }
                        
                        Action(symbol: "arrow.triangle.turn.up.right.circle") {
                            control.map.follow = false
                            control.points = true
                        }
                        .sheet(isPresented: $control.points) {
                            Sheet(rootView: Points(control: control))
                        }
                        
                        Action(symbol: "location.viewfinder", action: control.tracker)
                    }
                    .frame(height: 62)
                }
            }
            .preferredColorScheme(control.color)
    }
}
