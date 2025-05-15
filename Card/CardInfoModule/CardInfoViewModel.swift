import SwiftUI

class CardInfoViewModel: ObservableObject {
    let contact = CardInfoModel()
    @Published var currentIndex = 0
    @Published var dragOffset: CGFloat = 0
}
