import SwiftUI
import Offline

final class Session: ObservableObject {
    @Published var flow = Flow.main
    @Published var selected: (item: Item, namespace: Namespace.ID)?
    let local = Local()
}
