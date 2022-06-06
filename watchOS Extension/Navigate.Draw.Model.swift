import SwiftUI

extension Navigate.Draw {
    final class Model: ObservableObject {
        @Published private(set) var radius = Double(20)
        @Published private(set) var opacity = Double(0.1)
        
        func tick(date: Date, size: CGSize) {
            opacity = radius < 10 ? 0.1 : opacity + 0.005
            radius = radius < 10 ? 20 : radius - 0.075
            
        }
    }
}
