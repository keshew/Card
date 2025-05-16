import SwiftUI

struct CardShopView: View {
    @StateObject var cardShopModel =  CardShopViewModel()
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Binding var isShop: Bool
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if verticalSizeClass == .regular {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                Button(action: {
                                    isShop = false
                                }) {
                                    Image(.back)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                }
                                
                                Spacer()
                                
                                Image(.shop)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 200, height: 100)
                                    .padding(.leading, 30)
                                
                                Spacer()
                                
                                Image(.backForCoin)
                                    .resizable()
                                    .frame(width: 120, height: 70)
                                    .overlay {
                                        HStack(spacing: 1) {
                                            Text("\(UserDefaultsManager.defaults.integer(forKey: Keys.money.rawValue))")
                                                .CustomFont(size: 35, width: 0.4)
                                            
                                            Image(.coin)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                        }
                                    }
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                ForEach(cardShopModel.ud.shopItems.indices, id: \.self) { index in
                                    let item = cardShopModel.ud.shopItems[index]
                                    
                                    Image(item.backName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 350, height: 280)
                                        .overlay {
                                            VStack {
                                                Spacer()
                                                
                                                Button(action: {
                                                    cardShopModel.ud.manageShopItem(at: index)
                                                    cardShopModel.again = 1
                                                }) {
                                                    Image("backForBuy")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 150, height: 70)
                                                        .overlay {
                                                            Text(buttonTitle(for: item))
                                                                .CustomFont(size: 31, width: 0.2)
                                                        }
                                                }
                                                .offset(y: 50)
                                            }
                                        }
                                        .padding(.top, 200)
                                }
                            }

                            .padding(.top)
                        }
                        .padding(.top)
                    }
                    .scrollDisabled(UIScreen.main.bounds.height > 390 ? true : false)
                }
            }
        } else {
            if verticalSizeClass == .compact {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                Button(action: {
                                    isShop = false
                                }) {
                                    Image(.back)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                }
                                
                                Spacer()
                                
                                Image(.shop)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 200, height: 100)
                                    .padding(.leading, 30)
                                
                                Spacer()
                                
                                Image(.backForCoin)
                                    .resizable()
                                    .frame(width: 120, height: 70)
                                    .overlay {
                                        HStack(spacing: 1) {
                                            Text("\(UserDefaultsManager.defaults.integer(forKey: Keys.money.rawValue))")
                                                .CustomFont(size: 35, width: 0.4)
                                            
                                            Image(.coin)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                        }
                                    }
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                ForEach(cardShopModel.ud.shopItems.indices, id: \.self) { index in
                                    let item = cardShopModel.ud.shopItems[index]
                                    
                                    Image(item.backName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 250, height: 130)
                                        .overlay {
                                            VStack {
                                                Spacer()
                                                
                                                Button(action: {
                                                    cardShopModel.ud.manageShopItem(at: index)
                                                    cardShopModel.again = 1
                                                }) {
                                                    Image("backForBuy")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 150, height: 70)
                                                        .overlay {
                                                            Text(buttonTitle(for: item))
                                                                .CustomFont(size: 31, width: 0.2)
                                                        }
                                                }
                                                .offset(y: 50)
                                            }
                                        }
                                }
                            }

                            .padding(.top)
                        }
                        .padding(.top)
                    }
                    .scrollDisabled(UIScreen.main.bounds.height > 390 ? true : false)
                }
            }
        }
    }
    func buttonTitle(for item: ShopItemModel) -> String {
        if item.isSelected {
            return "EQUIPED"
        } else if item.isAvailible {
            return "EQUIP"
        } else {
            return "BUY"
        }
    }
}

#Preview {
    CardShopView(isShop: .constant(false))
}

