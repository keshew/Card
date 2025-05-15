import SwiftUI

struct ShopItemModel: Codable {
    var name: String
    var backName: String
    var isAvailible: Bool
    var isSelected: Bool
}

struct CardShopModel {
    let array = [ShopItemModel(name: "", backName: "spiderBackCard", isAvailible: true, isSelected: true),
                 ShopItemModel(name: "2", backName: "carpetBackCard", isAvailible: false, isSelected: false),
                 ShopItemModel(name: "3", backName: "agnesBackCard", isAvailible: false, isSelected: false)]
}


