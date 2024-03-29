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
                    withAnimation(.easeOut(duration: 0.4)) {
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
                withAnimation(.easeOut(duration: 0.4)) {
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
