import SwiftUI

class CardPauseViewModel: ObservableObject {
    let contact = CardPauseModel()
    @Published var isMenu = false
}
