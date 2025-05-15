import SwiftUI

class CardShopUndoViewModel: ObservableObject {
    let contact = CardShopUndoModel()
    @Published var again = 0
}
