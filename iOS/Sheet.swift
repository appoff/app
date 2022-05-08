import SwiftUI

final class Sheet<C>: UIHostingController<C>, UIViewControllerRepresentable where C : View {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sheetPresentationController
            .map {
                $0.detents = [.medium(), .large()]
                $0.preferredCornerRadius = 36
            }
    }
    
    func makeUIViewController(context: Context) -> Sheet {
        self
    }

    func updateUIViewController(_: Sheet, context: Context) {

    }
}
