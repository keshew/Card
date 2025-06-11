import SwiftUI

struct CreateAccountManagerView: UIViewControllerRepresentable {
    var managerKey: String
    
    func makeUIViewController(context: Context) -> CreateAccountManagerViewController {
        let viewController = CreateAccountManagerViewController()
        Task {
            await viewController.showControls()
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: CreateAccountManagerViewController, context: Context) {
        
    }
}
