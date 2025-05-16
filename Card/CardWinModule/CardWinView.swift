import SwiftUI

struct CardWinView: View {
    @StateObject var cardWinModel =  CardWinViewModel()
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State var isMenu = false
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
                                    isMenu = true
                                }) {
                                    Image(.back)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                }
                                
                                Spacer()
                                
                                Image(.victory)
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
                                            Image(.winLabel)
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
                                                isMenu = true
                                            }) {
                                                Image(.take)
                                                    .resizable()
                                                    .frame(width: 100, height: 60)
                                            }
                                            .offset(y: 120)
                                        }
                                    }
                                    .frame(width: 520, height: 270)
                                    .padding(.leading, 170)
                                    .padding(.top, getSpacing(for: UIScreen.main.bounds.width))
                                
                                Spacer()
                            }
                        }
                        .padding(.top)
                    }
                    .disabled(UIScreen.main.bounds.height > 390 ? true : false)
                }
                .fullScreenCover(isPresented: $isMenu) {
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
                                    isMenu = true
                                }) {
                                    Image(.back)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                }
                                
                                Spacer()
                                
                                Image(.victory)
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
                                            Image(.winLabel)
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
                                                isMenu = true
                                            }) {
                                                Image(.take)
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
                    .disabled(UIScreen.main.bounds.height > 390 ? true : false)
                }
                .fullScreenCover(isPresented: $isMenu) {
                    CardMenuView()
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
    CardWinView()
}

