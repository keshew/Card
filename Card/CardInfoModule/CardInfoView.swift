import SwiftUI

public enum CasesInfo: String {
    case first
    case second
    case third
}

struct CardInfoView: View {
    @StateObject var cardInfoModel =  CardInfoViewModel()
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var caseInfo: CasesInfo
    @Binding var isInfo: Bool
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if verticalSizeClass == .regular {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    
                    if cardInfoModel.currentIndex == 1 {
                        Image(.shyt2)
                            .resizable()
                            .frame(width: 560, height: 590)
                            .position(x: UIScreen.main.bounds.width / 4.6, y: UIScreen.main.bounds.height / 1.43)
                    } else {
                        Image(.shyt)
                            .resizable()
                            .frame(width: 560, height: 590)
                            .position(x: UIScreen.main.bounds.width / 1.5, y: UIScreen.main.bounds.height / 1.45)
                    }
                    
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                Button(action: {
                                    isInfo = false
                                }) {
                                    Image(.back)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                }
                                
                                Spacer()
                                
                                Image(.info)
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
                                if cardInfoModel.currentIndex == 1 {
                                    Spacer()
                                }
                                
                                Image(.backForCoin)
                                    .resizable()
                                    .overlay {
                                        VStack {
                                            switch caseInfo {
                                            case .first:
                                                Image(cardInfoModel.contact.firstInfo[cardInfoModel.currentIndex])
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 280, height: 90)
                                            case .second:
                                                Image(cardInfoModel.contact.secondInfo[cardInfoModel.currentIndex])
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 280, height: 90)
                                            case .third:
                                                Image(cardInfoModel.contact.thirdInfo[cardInfoModel.currentIndex])
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 280, height: 90)
                                            }
                                           
                                            HStack(spacing: 5) {
                                                Image(cardInfoModel.currentIndex == 0 ? .nowCircle : .circle)
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                
                                                Image(cardInfoModel.currentIndex == 1 ? .nowCircle : .circle)
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                
                                                Image(cardInfoModel.currentIndex == 2 ? .nowCircle : .circle)
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                            }
                                            .offset(y: 23)
                                        }
                                    }
                                    .frame(width: 520, height: 270)
                                    .padding(.leading, 200)
                                    .padding(.top, 400)
                                
                                if cardInfoModel.currentIndex != 1 {
                                    Spacer()
                                }
                            }
                        }
                        .padding(.top)
                    }
                    .scrollDisabled(UIScreen.main.bounds.height > 390 ? true : false)
                }
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onChanged { value in
                            cardInfoModel.dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            if abs(value.translation.width) > 50 {
                                if value.translation.width > 0 {
                                    withAnimation {
                                        
                                  
                                    cardInfoModel.currentIndex = max(0, cardInfoModel.currentIndex - 1)
                                    }
                                } else {
                                    withAnimation {
                                    cardInfoModel.currentIndex = min(2, cardInfoModel.currentIndex + 1)
                                }
                                }
                            }
                        }
                )
            }
        } else {
            if verticalSizeClass == .compact {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    
                    if cardInfoModel.currentIndex == 1 {
                        Image(.shyt2)
                            .resizable()
                            .frame(width: 360, height: 350)
                            .position(x: UIScreen.main.bounds.width / 4.6, y: UIScreen.main.bounds.height / 1.65)
                    } else {
                        Image(.shyt)
                            .resizable()
                            .frame(width: 260, height: 290)
                            .position(x: UIScreen.main.bounds.width / 1.5, y: UIScreen.main.bounds.height / 1.55)
                    }
                    
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                Button(action: {
                                    isInfo = false
                                }) {
                                    Image(.back)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                }
                                
                                Spacer()
                                
                                Image(.info)
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
                                
                                if cardInfoModel.currentIndex == 1 {
                                    Spacer()
                                }
                                
                                Image(.backForCoin)
                                    .resizable()
                                    .overlay {
                                        VStack {
                                            switch caseInfo {
                                            case .first:
                                                Image(cardInfoModel.contact.firstInfo[cardInfoModel.currentIndex])
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 280, height: 90)
                                            case .second:
                                                Image(cardInfoModel.contact.secondInfo[cardInfoModel.currentIndex])
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 280, height: 90)
                                            case .third:
                                                Image(cardInfoModel.contact.thirdInfo[cardInfoModel.currentIndex])
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 280, height: 90)
                                            }
                                           
                                            HStack(spacing: 5) {
                                                Image(cardInfoModel.currentIndex == 0 ? .nowCircle : .circle)
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                
                                                Image(cardInfoModel.currentIndex == 1 ? .nowCircle : .circle)
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                
                                                Image(cardInfoModel.currentIndex == 2 ? .nowCircle : .circle)
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                            }
                                            .offset(y: 23)
                                        }
                                    }
                                    .frame(width: 420, height: 220)
                                
                                if cardInfoModel.currentIndex != 1 {
                                    Spacer()
                                }
                            }
                        }
                        .padding(.top)
                    }
                    .scrollDisabled(UIScreen.main.bounds.height > 390 ? true : false)
                }
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onChanged { value in
                            cardInfoModel.dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            if abs(value.translation.width) > 50 {
                                if value.translation.width > 0 {
                                    withAnimation {
                                        
                                  
                                    cardInfoModel.currentIndex = max(0, cardInfoModel.currentIndex - 1)
                                    }
                                } else {
                                    withAnimation {
                                    cardInfoModel.currentIndex = min(2, cardInfoModel.currentIndex + 1)
                                }
                                }
                            }
                        }
                )
            }
        }
    }
}

#Preview {
    CardInfoView(caseInfo: CasesInfo.first, isInfo: .constant(false))
}

