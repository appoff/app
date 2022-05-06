import Foundation

final class Session: ObservableObject {
    @Published var flow = Flow.main
}
