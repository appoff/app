import AppKit
import Coffee
import Combine
import Offline

final class Navigate: NSView {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, schema: Schema, bufferer: Bufferer) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let divider = Separator()
        addSubview(divider)
        
        let control = Control(session: session, schema: schema, bufferer: bufferer)
        addSubview(control)
        
        divider.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        divider.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        divider.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        control.topAnchor.constraint(equalTo: divider.bottomAnchor).isActive = true
        control.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        control.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        control.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        session
            .options
            .sink { origin in
//                NSPopover()
//                    .show(content: Options(session: session,
//                                           scheme: builder.scheme,
//                                           rotate: builder.rotate),
//                          on: origin,
//                          edge: .minY)
            }
            .store(in: &subs)
        
        session
            .settings
            .sink { origin in
//                NSPopover()
//                    .show(content: Settings(type: builder.type,
//                                            directions: builder.directions,
//                                            interest: builder.interest),
//                          on: origin,
//                          edge: .minY)
            }
            .store(in: &subs)
    }
}

/*
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
                             control.config = true
                         }
                         .sheet(isPresented: $control.config) {
                             Sheet(rootView: Config(control: control))
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

 */
