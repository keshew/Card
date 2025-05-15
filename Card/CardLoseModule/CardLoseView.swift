import SwiftUI

struct CardLoseView: View {
    @StateObject var cardLoseModel =  CardLoseViewModel()
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if verticalSizeClass == .regular {
                
            }
        } else {
            if verticalSizeClass == .compact {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    
                    Image(.shyt4)
                        .resizable()
                        .frame(width: 310, height: 290)
                        .position(x: UIScreen.main.bounds.width / 1.5, y: UIScreen.main.bounds.height / 1.55)
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                Button(action: {
                                    
                                }) {
                                    Image(.back)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                }
                                
                                Spacer()
                                
                                Image(.lose)
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
                                            Image(.loseLabel)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 280, height: 90)
                                            
                                            HStack {
                                                Text("-60")
                                                    .CustomFont(size: 70, width: 0.4)
                                                
                                                Image(.coin)
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                            }
                                        }
                                        .offset(y: 25)
                                        .overlay {
                                            Button(action: {
                                                
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
            }
        }
    }
}

#Preview {
    CardLoseView()
}

