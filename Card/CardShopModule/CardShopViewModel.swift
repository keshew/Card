import SwiftUI

class CardShopViewModel: ObservableObject {
    let contact = CardShopModel()
    @Published var again = 0
    @Published var ud = UserDefaultsManager()
}
