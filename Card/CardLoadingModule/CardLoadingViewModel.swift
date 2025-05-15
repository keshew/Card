import SwiftUI

class CardLoadingViewModel: ObservableObject {
    let contact = CardLoadingModel()
    @Published var width: CGFloat = 0
    @Published var isAnimationDone = false
    
    func increaseWidth() {
        if width <= 672 {
            withAnimation(.linear(duration: 0.1)) {
                width += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.increaseWidth()
            }
        } else {
            isAnimationDone = true
        }
    }
}
