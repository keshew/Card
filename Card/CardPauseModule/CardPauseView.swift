import SwiftUI

struct CardPauseView: View {
    @StateObject var cardPauseModel =  CardPauseViewModel()
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Binding var isPause: Bool
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if verticalSizeClass == .regular {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    
                    Image(.shyt3)
                        .resizable()
                        .frame(width: 590, height: 590)
                        .position(x: UIScreen.main.bounds.width / 1.5, y: UIScreen.main.bounds.height / 1.45)
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                Button(action: {
                                    isPause = false
                                }) {
                                    Image(.back)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                }
                                
                                Spacer()
                                
                                Image(.pause)
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
                                        VStack(spacing: -35) {
                                            Image(.pauseLabel)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 330, height: 110)
                                          
                                        }
                                        .overlay {
                                            HStack(spacing: 80) {
                                                Button(action: {
                                                    cardPauseModel.isMenu = true
                                                }) {
                                                    Image(.menu)
                                                        .resizable()
                                                        .frame(width: 100, height: 60)
                                                }
                                                
                                                Button(action: {
                                                    isPause = false
                                                }) {
                                                    Image(.continue)
                                                        .resizable()
                                                        .frame(width: 100, height: 60)
                                                }
                                            }
                                            .offset(y: 110)
                                        }
                                    }
                                    .frame(width: 520, height: 270)
                                    .padding(.leading, 170)
                                    .padding(.top, 400)
                                
                                Spacer()
                            }
                        }
                        .padding(.top)
                    }
                    .scrollDisabled(UIScreen.main.bounds.height > 390 ? true : false)
                }
                .fullScreenCover(isPresented: $cardPauseModel.isMenu) {
                    CardMenuView()
                }
            }
        } else {
            if verticalSizeClass == .compact {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    
                    Image(.shyt3)
                        .resizable()
                        .frame(width: 310, height: 290)
                        .position(x: UIScreen.main.bounds.width / 1.5, y: UIScreen.main.bounds.height / 1.55)
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                Button(action: {
                                    isPause = false
                                }) {
                                    Image(.back)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                }
                                
                                Spacer()
                                
                                Image(.pause)
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
                                            Text("1000")
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
                                        VStack(spacing: -35) {
                                            Image(.pauseLabel)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 330, height: 110)
                                          
                                        }
                                        .overlay {
                                            HStack(spacing: 80) {
                                                Button(action: {
                                                    cardPauseModel.isMenu = true
                                                }) {
                                                    Image(.menu)
                                                        .resizable()
                                                        .frame(width: 100, height: 60)
                                                }
                                                
                                                Button(action: {
                                                    isPause = false
                                                }) {
                                                    Image(.continue)
                                                        .resizable()
                                                        .frame(width: 100, height: 60)
                                                }
                                            }
                                            .offset(y: 110)
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
                .fullScreenCover(isPresented: $cardPauseModel.isMenu) {
                    CardMenuView()
                }
            }
        }
    }
}

#Preview {
    CardPauseView(isPause: .constant(false))
}

