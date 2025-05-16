import SwiftUI

enum Keys: String {
    case money = "money"
    case firstItems = "firstItems"
    case soundEffectVolume = "soundEffectVolume"
    case shopItems = "shopItems"
    case hintCount = "hintCount"
    case undoCount = "undoCount"
    case isSoundEnabled = "isSoundEnabled"
    case isMusicEnabled = "isMusicEnabled"
}

class UserDefaultsManager: ObservableObject {
    static let defaults = UserDefaults.standard
    
    @Published var shopItems: [ShopItemModel] = [
        ShopItemModel(name: "", backName: "spiderBackCard", isAvailible: true, isSelected: true),
        ShopItemModel(name: "2", backName: "carpetBackCard", isAvailible: false, isSelected: false),
        ShopItemModel(name: "3", backName: "agnesBackCard", isAvailible: false, isSelected: false)
    ]
    
    init() {
        firstLaunch()
        
        if let savedItems = loadShopItems() {
            self.shopItems = savedItems
        }
    }
    
    func getSelectedShopItem() -> ShopItemModel? {
        return shopItems.first(where: { $0.isSelected })
    }

    func loadShopItems() -> [ShopItemModel]? {
        guard let savedItemsData = UserDefaultsManager.defaults.data(forKey: Keys.shopItems.rawValue) else {
            return nil
        }
        let decoder = JSONDecoder()
        if let loadedShopItems = try? decoder.decode([ShopItemModel].self, from: savedItemsData) {
            return loadedShopItems
        }
        return nil
    }
    
    func buyBonus(key: String) {
        let countOfMoney = UserDefaultsManager.defaults.integer(forKey: Keys.money.rawValue)
        let countOfBonus = UserDefaultsManager.defaults.integer(forKey: key)
        if countOfMoney >= 30 {
            UserDefaultsManager.defaults.set(countOfBonus + 1, forKey: key)
            UserDefaultsManager.defaults.set(countOfMoney - 30, forKey: Keys.money.rawValue)
        }
    }
    
    func useBonus(key: String) {
        let countOfBonus = UserDefaultsManager.defaults.integer(forKey: key)
        if countOfBonus > 0 {
            UserDefaultsManager.defaults.set(countOfBonus - 1, forKey: key)
        }
    }
    
    func saveShopItems() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(shopItems) {
            UserDefaultsManager.defaults.set(encoded, forKey: Keys.shopItems.rawValue)
        }
    }
    
    func getSelectedBackName() -> String? {
        return shopItems.first(where: { $0.isSelected })?.backName
    }
    
    func manageShopItem(at index: Int) {
        guard index >= 0 && index < shopItems.count else { return }
        
        var selectedItem = shopItems[index]
        
        if selectedItem.isSelected {
            return
        }
        
        if selectedItem.isAvailible {
            for i in 0..<shopItems.count {
                if shopItems[i].isSelected {
                    shopItems[i].isSelected = false
                    shopItems[i].isAvailible = true
                    break
                }
            }
            selectedItem.isSelected = true
            selectedItem.isAvailible = false
        } else {
            let countOfMoney = UserDefaultsManager.defaults.integer(forKey: Keys.money.rawValue)
            if countOfMoney >= 250 {
                selectedItem.isAvailible = true
                
                for i in 0..<shopItems.count {
                    if shopItems[i].isSelected {
                        shopItems[i].isSelected = false
                        shopItems[i].isAvailible = true
                        break
                    }
                }
                
                selectedItem.isSelected = true
                selectedItem.isAvailible = false
                
                UserDefaultsManager.defaults.set(countOfMoney - 250, forKey: Keys.money.rawValue)
            } else {
                return
            }
        }
        
        shopItems[index] = selectedItem
        saveShopItems()
    }
    
    func firstLaunch() {
        if UserDefaultsManager.defaults.object(forKey: Keys.money.rawValue) == nil {
            UserDefaultsManager.defaults.set(1000, forKey: Keys.money.rawValue)
            UserDefaultsManager.defaults.set(true, forKey: Keys.isSoundEnabled.rawValue)
            UserDefaultsManager.defaults.set(true, forKey: Keys.isMusicEnabled.rawValue)
            saveShopItems()
        }
    }
    
    func completeLevel() {
        let money = UserDefaultsManager.defaults.integer(forKey: Keys.money.rawValue)
        UserDefaultsManager.defaults.set(money + 30, forKey: Keys.money.rawValue)
    }
    
    func updateResource(keyToUpdate key: Keys, costInMoney cost: Int, countOfResourse: Int) {
        let resource = UserDefaultsManager.defaults.integer(forKey: key.rawValue)
        let money = UserDefaultsManager.defaults.integer(forKey: Keys.money.rawValue)
        
        if money >= cost {
            UserDefaultsManager.defaults.set(resource + countOfResourse, forKey: key.rawValue)
            UserDefaultsManager.defaults.set(money - cost, forKey: Keys.money.rawValue)
        }
    }
    
    
    func toggleMusic() {
        let current = isMusicEnabled()
        UserDefaults.standard.set(!current, forKey: Keys.isMusicEnabled.rawValue)
        objectWillChange.send()
    }
    
    func toggleSound() {
        let current = isSoundEnabled()
        UserDefaults.standard.set(!current, forKey: Keys.isSoundEnabled.rawValue)
        objectWillChange.send()
    }
    
    func saveSoundSettings(isSoundEnabled: Bool) {
        UserDefaultsManager.defaults.set(isSoundEnabled, forKey: Keys.isSoundEnabled.rawValue)
    }
    
    func saveMusicSettings(isMusicEnabled: Bool) {
        UserDefaultsManager.defaults.set(isMusicEnabled, forKey: Keys.isMusicEnabled.rawValue)
    }
    
    func isSoundEnabled() -> Bool {
        return UserDefaultsManager.defaults.bool(forKey: Keys.isSoundEnabled.rawValue)
    }
    
    func isMusicEnabled() -> Bool {
        return UserDefaultsManager.defaults.bool(forKey: Keys.isMusicEnabled.rawValue)
    }
}
