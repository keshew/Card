import SwiftUI

struct CardDailyView: View {
    @StateObject var cardDailyModel =  CardDailyViewModel()
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Binding var isDaily: Bool
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if verticalSizeClass == .regular {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    
                    Image(.shyt)
                        .resizable()
                        .frame(width: 560, height: 590)
                        .position(x: UIScreen.main.bounds.width / 1.5, y: UIScreen.main.bounds.height / 1.45)
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                Button(action: {
                                    isDaily = false
                                }) {
                                    Image(.back)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                }
                                
                                Spacer()
                                
                                Image(.dailyText)
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
                                        VStack(spacing: -35) {
                                            Image(.dailyRewardText)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 280, height: 90)
                                            
                                            HStack {
                                                Text("+30")
                                                    .CustomFont(size: 70, width: 0.4)
                                                
                                                Image(.coin)
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                            }
                                        }
                                        .offset(y: 25)
                                        .overlay {
                                            Button(action: {
                                                isDaily = false
                                            }) {
                                                Image(.take)
                                                    .resizable()
                                                    .frame(width: 100, height: 60)
                                            }
                                            .offset(y: 120)
                                        }
                                    }
                                    .frame(width: 520, height: 270)
                                    .padding(.leading, 200)
                                    .padding(.top, 400)
                                
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
                    Color.black.opacity(0.8).ignoresSafeArea()
                    
                    Image(.shyt)
                        .resizable()
                        .frame(width: 260, height: 290)
                        .position(x: UIScreen.main.bounds.width / 1.5, y: UIScreen.main.bounds.height / 1.55)
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                Button(action: {
                                    isDaily = false
                                }) {
                                    Image(.back)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                }
                                
                                Spacer()
                                
                                Image(.dailyText)
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
                            .padding(.horizontal, 40)
                            
                            HStack {
                                Image(.backForCoin)
                                    .resizable()
                                    .overlay {
                                        VStack(spacing: -35) {
                                            Image(.dailyRewardText)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 280, height: 90)
                                            
                                            HStack {
                                                Text("+30")
                                                    .CustomFont(size: 70, width: 0.4)
                                                
                                                Image(.coin)
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                            }
                                        }
                                        .offset(y: 25)
                                        .overlay {
                                            Button(action: {
                                                isDaily = false
                                            }) {
                                                Image(.take)
                                                    .resizable()
                                                    .frame(width: 100, height: 60)
                                            }
                                            .offset(y: 120)
                                        }
                                    }
                                    .frame(width: 420, height: 220)
                                    .padding(.leading)
                                
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
}

#Preview {
    CardDailyView(isDaily: .constant(false))
}
