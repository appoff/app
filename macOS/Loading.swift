import AppKit
import Coffee
import Combine
import Offline

private let rotate = Double.pi / 10
private let offsetting = Double(5)

final class Loading: NSView {
    private var subs = Set<AnyCancellable>()
    private let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, factory: Factory) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        var waiting = false
        var error = false
        
        let image = NSImageView(image: .init(named: "Loading") ?? .init())
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentTintColor = .secondaryLabelColor
        addSubview(image)
        
        let base = NSView()
        base.wantsLayer = true
        base.translatesAutoresizingMaskIntoConstraints = false
        base.layer!.backgroundColor = NSColor.unemphasizedSelectedTextBackgroundColor.cgColor
        base.layer!.cornerRadius = 5
        addSubview(base)
        
        let progress = NSView()
        progress.wantsLayer = true
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.layer!.backgroundColor = NSColor.labelColor.cgColor
        progress.layer!.cornerRadius = 7
        addSubview(progress)
        
        let header = Text(vibrancy: false)
        header.stringValue = "Loading"
        header.font = .preferredFont(forTextStyle: .title1)
        header.textColor = .secondaryLabelColor
        addSubview(header)
        
        let title = Text(vibrancy: false)
        title.stringValue = factory.header.title
        title.font = .preferredFont(forTextStyle: .title3)
        title.textColor = .tertiaryLabelColor
        addSubview(title)
        
        let warning = NSImageView(image: .init(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil) ?? .init())
        warning.isHidden = true
        warning.translatesAutoresizingMaskIntoConstraints = false
        warning.symbolConfiguration = .init(pointSize: 50, weight: .ultraLight)
            .applying(.init(hierarchicalColor: .secondaryLabelColor))
        addSubview(warning)
        
        let fail = Text(vibrancy: false)
        fail.isHidden = true
        fail.textColor = .secondaryLabelColor
        fail.font = .preferredFont(forTextStyle: .title2)
        fail.stringValue = "Loading failed"
        addSubview(fail)
        
        let tryAgain = Control.Prominent(title: "Try again")
        tryAgain.state = .hidden
        tryAgain
            .click
            .sink {
                error = false
                
                
                
            }
            .store(in: &subs)
        addSubview(tryAgain)
        
        let cancel = Control.Plain(title: "Cancel")
        cancel
            .click
            .sink { [weak self] in
                let alert = NSAlert()
                alert.alertStyle = .warning
                alert.icon = .init(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: nil)
                alert.messageText = "Stop loading map?"
                
                let stop = alert.addButton(withTitle: "Stop")
                let cont = alert.addButton(withTitle: "Continue")
                stop.hasDestructiveAction = true
                stop.keyEquivalent = "\r"
                cont.keyEquivalent = "\u{1b}"
                
                if alert.runModal().rawValue == stop.tag {
                    factory.cancel()
                    session.flow.value = .main
                    self?.window?.makeFirstResponder(self?.window?.contentView)
                }
            }
            .store(in: &subs)
        addSubview(cancel)
        
        image.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        
        base.widthAnchor.constraint(equalToConstant: 70).isActive = true
        base.heightAnchor.constraint(equalToConstant: 10).isActive = true
        base.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 25).isActive = true
        
        progress.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        progress.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        progress.heightAnchor.constraint(equalToConstant: 14).isActive = true
        let progressWidth = progress.widthAnchor.constraint(equalToConstant: 0)
        progressWidth.isActive = true
        
        header.topAnchor.constraint(equalTo: progress.bottomAnchor, constant: 42).isActive = true
        
        title.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 4).isActive = true
        
        warning.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        
        fail.topAnchor.constraint(equalTo: warning.bottomAnchor, constant: 20).isActive = true
        
        tryAgain.topAnchor.constraint(equalTo: fail.bottomAnchor, constant: 40).isActive = true
        tryAgain.widthAnchor.constraint(equalToConstant: 120).isActive = true
        tryAgain.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        cancel.topAnchor.constraint(equalTo: tryAgain.bottomAnchor, constant: 20).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        [image, base, header, title, warning, fail, tryAgain, cancel]
            .forEach {
                $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            }
        
        factory
            .fail
            .sink {
                error = true
                header.isHidden = true
                title.isHidden = true
                warning.isHidden = false
                fail.isHidden = false
                tryAgain.state = .on
            }
            .store(in: &subs)
        
        factory
            .progress
            .sink {
                progressWidth.constant = 70 * $0
            }
            .store(in: &subs)
        
        factory
            .finished
            .sink { schema in
                Task {
                    await cloud.add(header: factory.header, schema: schema)
//                    session.flow.value = .created(factory.header)
                }
            }
            .store(in: &subs)
        
        /*
         imageView.setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 0.5))
             // Start animation
             if imageView.layer?.animationKeys()?.count == 0 || imageView.layer?.animationKeys() == nil {
                 let rotate = CABasicAnimation(keyPath: "transform.rotation")
                 rotate.fromValue = 0
                 rotate.toValue = CGFloat(-1 * .pi * 2.0)
                 rotate.duration = 2
                 rotate.repeatCount = Float.infinity

                 imageView.layer?.add(rotate, forKey: "rotation")
             }
         */
        
        timer
            .sink { _ in
                guard waiting, !error else { return }
                
                switch Int.random(in: 0 ..< 80) {
                case 0:
                    waiting = false
                    
//                    withAnimation(.easeInOut(duration: 0.5)) {
//                        rotation = rotate
//                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        withAnimation(.easeInOut(duration: 0.5)) {
//                            rotation = -rotate
//                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        withAnimation(.easeInOut(duration: 0.5)) {
//                            rotation = 0
//                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        waiting = true
                    }
                case 1:
                    waiting = false
                    
//                    withAnimation(.easeInOut(duration: 0.2)) {
//                        offset = offsetting
//                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            offset = -offsetting
//                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            offset = 0
//                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        waiting = true
                    }
                default:
                    break
                }
            }
            .store(in: &subs)
        
        Task {
//            await factory.shoot()
        }
    }
    
    override var allowsVibrancy: Bool {
        true
    }
}


/*
 import SwiftUI
 import Offline

 private let rotate = Double.pi / 10
 private let offsetting = Double(5)

 struct Loading: View {
     let session: Session
     let factory: Factory
     @State private var error = false
     @State private var cancel = false
     @State private var waiting = true
     @State private var progress = Double()
     @State private var rotation = Double()
     @State private var offset = Double()
     private let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
     
     var body: some View {
         VStack {
             Spacer()
             Image("Loading")
                 .rotationEffect(.init(radians: rotation), anchor: .bottom)
                 .offset(x: offset)
                 .foregroundColor(.primary)
             ZStack {
                 Progress(value: 1)
                     .stroke(Color(.secondarySystemBackground), style: .init(lineWidth: 10, lineCap: .round))
                 Progress(value: progress)
                     .stroke(Color.primary, style: .init(lineWidth: 14, lineCap: .round))
             }
             .frame(width: 70)
             .fixedSize()
             .padding(.vertical)
             
             if error {
                 Image(systemName: "exclamationmark.triangle")
                     .font(.system(size: 50, weight: .ultraLight))
                     .symbolRenderingMode(.hierarchical)
                     .padding(.vertical)
                 Text("Loading failed")
                     .font(.body)
                 Spacer()
                 Button {
                     error = false
                     Task {
                         await factory.shoot()
                     }
                 } label: {
                     Text("Try again")
                         .font(.body.weight(.bold))
                         .foregroundColor(.primary)
                         .padding()
                         .contentShape(Rectangle())
                 }
                 .padding(.bottom)
             } else {
                 Text("Loading")
                     .font(.title2.weight(.regular))
                     .padding(.top)
                 Text(factory.header.title)
                     .font(.callout)
                     .foregroundStyle(.secondary)
                     .lineLimit(1)
                     .frame(maxWidth: 280)
                 Spacer()
             }
             
             Button(role: .destructive) {
                 cancel = true
             } label: {
                 Text("Cancel")
                     .font(.callout.weight(.medium))
                     .foregroundColor(.secondary)
                     .padding()
                     .contentShape(Rectangle())
             }
             .padding(.bottom, 30)
             .confirmationDialog("Cancel map?", isPresented: $cancel) {
                 Button("Continue", role: .cancel) { }
                 Button("Cancel map", role: .destructive) {
                     UIApplication.shared.isIdleTimerDisabled = false
                     
                     factory.cancel()
                     withAnimation(.easeInOut(duration: 0.4)) {
                         session.flow = .main
                     }
                 }
             }
         }
         .onReceive(timer) { _ in
             guard waiting, !error else { return }
             switch Int.random(in: 0 ..< 80) {
             case 0:
                 move()
             case 1:
                 shake()
             default:
                 break
             }
         }
         .onReceive(factory.progress) {
             progress = $0
         }
         .onReceive(factory.fail) {
             error = true
         }
         .onReceive(factory.finished) { schema in
             UIApplication.shared.isIdleTimerDisabled = false
             
             Task {
                 await cloud.add(header: factory.header, schema: schema)
                 withAnimation(.easeInOut(duration: 0.4)) {
                     session.flow = .created(factory.header)
                 }
             }
         }
         .task {
             UIApplication.shared.isIdleTimerDisabled = true
             
             await factory.shoot()
         }
     }
     
     private func move() {
         waiting = false
         
         withAnimation(.easeInOut(duration: 0.5)) {
             rotation = rotate
         }
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
             withAnimation(.easeInOut(duration: 0.5)) {
                 rotation = -rotate
             }
         }
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
             withAnimation(.easeInOut(duration: 0.5)) {
                 rotation = 0
             }
         }
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
             waiting = true
         }
     }
     
     private func shake() {
         waiting = false
         
         withAnimation(.easeInOut(duration: 0.2)) {
             offset = offsetting
         }
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
             withAnimation(.easeInOut(duration: 0.2)) {
                 offset = -offsetting
             }
         }
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
             withAnimation(.easeInOut(duration: 0.2)) {
                 offset = 0
             }
         }
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
             waiting = true
         }
     }
 }

 */
