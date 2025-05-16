import SwiftUI

struct CardMenuView: View {
    @StateObject var cardMenuModel =  CardMenuViewModel()
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State var isShop = false
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if verticalSizeClass == .regular {
                ZStack {
                    Image(.bg)
                        .resizable()
                        .ignoresSafeArea()
                    
                    Image(.shyt)
                        .resizable()
                        .frame(width: 580, height: 590)
                        .scaleEffect(x: -1, y: 1)
                        .position(x: UIScreen.main.bounds.width / 5.3, y: UIScreen.main.bounds.height / 1.45)
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            Rectangle()
                                .fill(LinearGradient(colors: [Color(red: 137/255, green: 1/255, blue: 112/255), Color(red: 40/255, green: 0/255, blue: 31/255)], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(15)
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.white, lineWidth: 1)
                                        .overlay {
                                            HStack {
                                                Button(action: {
                                                    cardMenuModel.isMusic.toggle()
                                                }) {
                                                    Image(cardMenuModel.isMusic ? .music : .musicOff)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 60, height: 60)
                                                }
                                                
                                                Button(action: {
                                                    cardMenuModel.isSound.toggle()
                                                }) {
                                                    Image(cardMenuModel.isSound ? .sound : .soundOff)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 60, height: 60)
                                                }
                                                
                                                Spacer()
                                                
                                                Image(.chooseGameLabel)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 460, height: 100)
                                                    .offset(x: 10, y: 6)
                                                
                                                Spacer()
                                                
                                                HStack {
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
                                                        .offset(y: 6)
                                                    
                                                    Button(action: {
                                                        isShop = true
                                                    }) {
                                                        Image(.backForShop)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 60, height: 60)
                                                            .overlay {
                                                                Text("SHOP")
                                                                    .CustomFont(size: 22, width: 0.3)
                                                            }
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 40)
                                        }
                                })
                                .frame(width: UIScreen.main.bounds.width, height: 165)
                                .offset(y: -30)
                            
                            HStack {
                                Spacer()
                                
                                Image(.game1)
                                    .resizable()
                                    .frame(width: 250, height: 300)
                                    .overlay {
                                        VStack {
                                            Image(.game1Label)
                                                .resizable()
                                                .frame(width: 200, height: 105)
                                                .offset(y: -10)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                cardMenuModel.isFirstGame = true
                                            }) {
                                                Image(.play)
                                                    .resizable()
                                                    .frame(width: 200, height: 105)
                                            }
                                            .offset(y: 60)
                                        }
                                    }
                                
                                
                                Image(.game2)
                                    .resizable()
                                    .frame(width: 250, height: 300)
                                    .overlay {
                                        VStack {
                                            Image(.game2Label)
                                                .resizable()
                                                .frame(width: 200, height: 105)
                                                .offset(y: -10)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                cardMenuModel.isSecondGame = true
                                            }) {
                                                Image(.play)
                                                    .resizable()
                                                    .frame(width: 200, height: 105)
                                            }
                                            .offset(y: 60)
                                        }
                                    }
                                
                                Image(.game3)
                                    .resizable()
                                    .frame(width: 250, height: 300)
                                    .overlay {
                                        VStack {
                                            Image(.game3Label)
                                                .resizable()
                                                .frame(width: 200, height: 105)
                                                .offset(y: -10)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                cardMenuModel.isThirdGame = true
                                            }) {
                                                Image(.play)
                                                    .resizable()
                                                    .frame(width: 200, height: 105)
                                            }
                                            .offset(y: 60)
                                        }
                                    }
                                
                                Button(action: {
                                    if cardMenuModel.canTransition() {
                                        cardMenuModel.recordTransition()
                                        cardMenuModel.isDaily = true
                                        UserDefaultsManager().completeLevel()
                                    }
                                }) {
                                    if cardMenuModel.canTransition() {
                                        Image(.daily)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 120, height: 120)
                                            .padding(.top, 150)
                                    } else {
                                        Image(.backForDaily)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 70, height: 70)
                                            .overlay {
                                                VStack(spacing: -10) {
                                                    Image(.sunduk)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 40, height: 40)
                                                    
                                                    Text(cardMenuModel.formattedRemainingTime())
                                                        .CustomFont(size: 15, width: 0.2)
                                                }
                                                .offset(y: 5)
                                            }
                                    }
                                }
                                .offset(y: 90)
                                .padding(.leading)
                                .disabled(!cardMenuModel.canTransition())
                            }
                            .padding(.trailing, 30)
                            .padding(.top, 305)
                        }
                    }
                    .scrollDisabled(UIScreen.main.bounds.height > 390 ? true : false)
                    
                    if isShop {
                        CardShopView(isShop: $isShop)
                            .ignoresSafeArea()
                    }
                    
                    if cardMenuModel.isDaily {
                        CardDailyView(isDaily: $cardMenuModel.isDaily)
                            .ignoresSafeArea()
                    }
                }
                .fullScreenCover(isPresented: $cardMenuModel.isFirstGame) {
                    CardSpiderGameView()
                }
                .fullScreenCover(isPresented: $cardMenuModel.isSecondGame) {
                    CardAgnesGameView()
                }
                .fullScreenCover(isPresented: $cardMenuModel.isThirdGame) {
                    CardCarpetGameView()
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
                        .frame(width: 280, height: 290)
                        .scaleEffect(x: -1, y: 1)
                        .position(x: UIScreen.main.bounds.width / 5.3, y: UIScreen.main.bounds.height / 1.55)
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            Rectangle()
                                .fill(LinearGradient(colors: [Color(red: 137/255, green: 1/255, blue: 112/255), Color(red: 40/255, green: 0/255, blue: 31/255)], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(15)
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.white, lineWidth: 1)
                                        .overlay {
                                            HStack {
                                                Button(action: {
                                                    cardMenuModel.isMusic.toggle()
                                                }) {
                                                    Image(cardMenuModel.isMusic ? .music : .musicOff)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 60, height: 60)
                                                }
                                                
                                                Button(action: {
                                                    cardMenuModel.isSound.toggle()
                                                }) {
                                                    Image(cardMenuModel.isSound ? .sound : .soundOff)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 60, height: 60)
                                                }
                                                
                                                Image(.chooseGameLabel)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 460, height: 100)
                                                    .offset(x: 10, y: 6)
                                                
                                                HStack {
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
                                                        .offset(y: 6)
                                                    
                                                    Button(action: {
                                                        isShop = true
                                                    }) {
                                                        Image(.backForShop)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 60, height: 60)
                                                            .overlay {
                                                                Text("SHOP")
                                                                    .CustomFont(size: 22, width: 0.3)
                                                            }
                                                    }
                                                }
                                            }
                                        }
                                })
                                .frame(width: UIScreen.main.bounds.width, height: 115)
                                .offset(y: -10)
                            
                            HStack {
                                Spacer()
                                
                                Image(.game1)
                                    .resizable()
                                    .frame(width: 150, height: 200)
                                    .overlay {
                                        VStack {
                                            Image(.game1Label)
                                                .resizable()
                                                .frame(width: 100, height: 55)
                                                .offset(y: -10)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                cardMenuModel.isFirstGame = true
                                            }) {
                                                Image(.play)
                                                    .resizable()
                                                    .frame(width: 100, height: 55)
                                            }
                                            .offset(y: 20)
                                        }
                                    }
                                
                                
                                Image(.game2)
                                    .resizable()
                                    .frame(width: 150, height: 200)
                                    .overlay {
                                        VStack {
                                            Image(.game2Label)
                                                .resizable()
                                                .frame(width: 100, height: 55)
                                                .offset(y: -10)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                cardMenuModel.isSecondGame = true
                                            }) {
                                                Image(.play)
                                                    .resizable()
                                                    .frame(width: 100, height: 55)
                                            }
                                            .offset(y: 20)
                                        }
                                    }
                                
                                Image(.game3)
                                    .resizable()
                                    .frame(width: 150, height: 200)
                                    .overlay {
                                        VStack {
                                            Image(.game3Label)
                                                .resizable()
                                                .frame(width: 100, height: 55)
                                                .offset(y: -10)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                cardMenuModel.isThirdGame = true
                                            }) {
                                                Image(.play)
                                                    .resizable()
                                                    .frame(width: 100, height: 55)
                                            }
                                            .offset(y: 20)
                                        }
                                    }
                                
                                Button(action: {
                                    if cardMenuModel.canTransition() {
                                        cardMenuModel.recordTransition()
                                        cardMenuModel.isDaily = true
                                        UserDefaultsManager().completeLevel()
                                    }
                                }) {
                                    if cardMenuModel.canTransition() {
                                        Image(.daily)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 70, height: 70)
                                    } else {
                                        Image(.backForDaily)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                            .overlay {
                                                VStack(spacing: -10) {
                                                    Image(.sunduk)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 20, height: 20)
                                                    
                                                    Text(cardMenuModel.formattedRemainingTime())
                                                        .CustomFont(size: 15, width: 0.2)
                                                }
                                                .offset(y: 5)
                                            }
                                    }
                                }
                                .offset(y: 90)
                                .padding(.leading)
                                .disabled(!cardMenuModel.canTransition())
                            }
                            .padding(.trailing, 60)
                            .padding(.top, 15)
                        }
                    }
                    .scrollDisabled(UIScreen.main.bounds.height > 390 ? true : false)
                    
                    if isShop {
                        CardShopView(isShop: $isShop)
                            .ignoresSafeArea()
                    }
                    
                    if cardMenuModel.isDaily {
                        CardDailyView(isDaily: $cardMenuModel.isDaily)
                            .ignoresSafeArea()
                    }
                }
                .fullScreenCover(isPresented: $cardMenuModel.isFirstGame) {
                    CardSpiderGameView()
                }
                .fullScreenCover(isPresented: $cardMenuModel.isSecondGame) {
                    CardAgnesGameView()
                }
                .fullScreenCover(isPresented: $cardMenuModel.isThirdGame) {
                    CardCarpetGameView()
                }
            }
        }
    }
}

#Preview {
    CardMenuView()
}

