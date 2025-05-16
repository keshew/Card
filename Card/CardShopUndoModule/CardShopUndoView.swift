import SwiftUI

struct CardShopUndoView: View {
    @StateObject var cardShopUndoModel =  CardShopUndoViewModel()
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State var ud = UserDefaultsManager()
    @Binding var isShow: Bool
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if verticalSizeClass == .regular {
                ZStack {
                    Image(.bg)
                        .resizable()
                        .ignoresSafeArea()
                    
                    Image(.shyt)
                        .resizable()
                        .frame(width: 560, height: 590)
                        .position(x: UIScreen.main.bounds.width / 1.3, y: UIScreen.main.bounds.height / 1.45)
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                Button(action: {
                                    isShow = false
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
                            .padding(.horizontal, 40)
                            
                            HStack {
                                Image(.backForCoin)
                                    .resizable()
                                    .overlay {
                                        VStack(spacing: -110) {
                                            Image(.textShopUndo)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 280, height: 300)
                                            
                                            HStack {
                                                Image(.undo)
                                                    .resizable()
                                                    .frame(width: 70, height: 80)
                                                
                                                Text("30 COINS")
                                                    .CustomFont(size: 40, width: 0.4)
                                            }
                                        }
                                        .offset(y: -40)
                                        .overlay {
                                            Button(action: {
                                                ud.buyBonus(key: Keys.undoCount.rawValue)
                                                cardShopUndoModel.again = 1
                                            }) {
                                                Image(.buy)
                                                    .resizable()
                                                    .frame(width: 100, height: 60)
                                            }
                                            .offset(y: 120)
                                        }
                                    }
                                    .frame(width: 520, height: 270)
                                    .padding(.leading, 200)
                                    .padding(.top, getSpacing(for: UIScreen.main.bounds.width))
                                
                                Spacer()
                            }
                        }
                        .padding(.top)
                    }
                    .scrollDisabled(UIScreen.main.bounds.height > 390 ? true : false)
                }
            }
        } else {
            if verticalSizeClass == .compact {
                ZStack {
                    Image(.bg)
                        .resizable()
                        .ignoresSafeArea()
                    
                    Image(.shyt)
                        .resizable()
                        .frame(width: 260, height: 290)
                        .position(x: UIScreen.main.bounds.width / 1.5, y: UIScreen.main.bounds.height / 1.55)
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                Button(action: {
                                    isShow = false
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
                                Image(.backForCoin)
                                    .resizable()
                                    .overlay {
                                        VStack(spacing: -110) {
                                            Image(.textShopUndo)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 280, height: 300)
                                            
                                            HStack {
                                                Image(.undo)
                                                    .resizable()
                                                    .frame(width: 70, height: 80)
                                                
                                                Text("30 COINS")
                                                    .CustomFont(size: 40, width: 0.4)
                                            }
                                        }
                                        .offset(y: -40)
                                        .overlay {
                                            Button(action: {
                                                ud.buyBonus(key: Keys.undoCount.rawValue)
                                                cardShopUndoModel.again = 1
                                            }) {
                                                Image(.buy)
                                                    .resizable()
                                                    .frame(width: 100, height: 60)
                                            }
                                            .offset(y: 120)
                                        }
                                    }
                                    .frame(width: 420, height: 220)
                                
                                Spacer()
                            }
                        }
                        .padding(.top)
                    }
                    .scrollDisabled(UIScreen.main.bounds.height > 390 ? true : false)
                }
            }
        }
    }
    
    func getSpacing(for width: CGFloat) -> CGFloat {
        if width > 1370 {
            return 400
        } else if width > 1200 {
            return 300
        } else {
            return 660
        }
    }
}

#Preview {
    CardShopUndoView(isShow: .constant(false))
}

