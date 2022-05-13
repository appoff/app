import SwiftUI
import Offline

struct Loading: View {
    let session: Session
    let factory: Factory
    @State private var progress = Double()
    @State private var error = false
    @State private var cancel = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                Image(systemName: "map.circle.fill")
                    .font(.system(size: 100, weight: .ultraLight))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.quaternary)
                    .padding(.top, 30)
                HStack {
                    Button("Cancel") {
                        cancel = true
                    }
                    .font(.callout)
                    .buttonStyle(.bordered)
                    .confirmationDialog("Cancel map?", isPresented: $cancel) {
                        Button("Continue", role: .cancel) { }
                        Button("Cancel map", role: .destructive) {
                            factory.cancel()
                            done()
                        }
                    }
                    Spacer()
                }
            }
            Spacer()
            if error {
                Text("There was an error creating your map.")
                    .font(.callout)
                Button("Try again") {
                    error = false
                    Task {
                        await factory.shoot()
                    }
                }
                .font(.callout)
                .buttonStyle(.borderedProminent)
                .foregroundColor(Color(.systemBackground))
                .tint(.primary)
            } else {
                VStack(alignment: .leading) {
                    Item(title: "Title", content: .init(factory.map.title))
                    Divider()
                    Item(title: "Origin", content: .init(factory.map.origin))
                    Divider()
                    Item(title: "Destination", content: .init(factory.map.destination))
                    Divider()
                    Item(title: "Duration", content: .init(Date(timeIntervalSinceNow: -.init(factory.map.duration)) ..< Date.now, format: .timeDuration))
                    Divider()
                    Item(title: "Distance", content: .init(Measurement(value: .init(factory.map.distance), unit: UnitLength.meters),
                                                                   format: .measurement(width: .wide)))
                }
                .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
            }
            Spacer()
            Text(progress, format: .percent.precision(.significantDigits(2)))
                .font(.title3.monospacedDigit())
                .padding(.top)
            ZStack {
                Progress(value: 1)
                    .stroke(Color(.secondarySystemBackground), style: .init(lineWidth: 8, lineCap: .round))
                Progress(value: progress)
                    .stroke(Color.primary, style: .init(lineWidth: 10, lineCap: .round))
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding([.top, .leading, .trailing])
        .onReceive(factory.progress) {
            progress = $0
        }
        .onReceive(factory.fail) {
            error = true
        }
        .onReceive(factory.finished) {
            Task {
                await cloud.add(map: factory.map)
                done()
            }
        }
        .task {
            print("here shot")
            await factory.shoot()
        }
    }
    
    private func done() {
        withAnimation(.easeInOut(duration: 0.4)) {
            session.flow = .main
        }
    }
}
