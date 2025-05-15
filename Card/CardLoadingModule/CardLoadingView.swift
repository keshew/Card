import SwiftUI

struct CardLoadingView: View {
    @StateObject var cardLoadingModel =  CardLoadingViewModel()
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if verticalSizeClass == .regular {
                ZStack {
                    Image(.bg)
                        .resizable()
                        .ignoresSafeArea()
                    
                    Image(.shyt)
                        .resizable()
                        .frame(width: 510, height: 530)
                        .position(x: UIScreen.main.bounds.width / 1.3, y: UIScreen.main.bounds.height / 1.38)
                    
                    VStack {
                        Spacer()
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(.clear)
                                .cornerRadius(20)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(LinearGradient(colors: [Color(red: 255/255, green: 245/255, blue: 0/255), Color(red: 255/255, green: 184/255, blue: 0/255)], startPoint: .leading, endPoint: .trailing))
                                }
                                .frame(width: 673, height: 20)
                            
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(colors: [.black, Color(red: 159/255, green: 25/255, blue: 25/255), Color(red: 222/255, green: 0/255, blue: 11/255), Color(red: 159/255, green: 25/255, blue: 25/255), .black], startPoint: .leading, endPoint: .trailing))
                                .frame(width: cardLoadingModel.width, height: 18)
                                .padding(.horizontal, 1)
                        }
                    }
                }
                .onAppear() {
                    cardLoadingModel.increaseWidth()
                }
                
                .fullScreenCover(isPresented: $cardLoadingModel.isAnimationDone) {
                    CardMenuView()
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
                        .frame(width: 310, height: 330)
                        .position(x: UIScreen.main.bounds.width / 1.5, y: UIScreen.main.bounds.height / 1.65)
                    
                    VStack {
                        Spacer()
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(.clear)
                                .cornerRadius(20)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(LinearGradient(colors: [Color(red: 255/255, green: 245/255, blue: 0/255), Color(red: 255/255, green: 184/255, blue: 0/255)], startPoint: .leading, endPoint: .trailing))
                                }
                                .frame(height: 20)
                            
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(colors: [.black, Color(red: 159/255, green: 25/255, blue: 25/255), Color(red: 222/255, green: 0/255, blue: 11/255), Color(red: 159/255, green: 25/255, blue: 25/255), .black], startPoint: .leading, endPoint: .trailing))
                                .frame(width: cardLoadingModel.width, height: 18)
                                .padding(.horizontal, 1)
                        }
                        
                    }
                }
                .onAppear() {
                    cardLoadingModel.increaseWidth()
                }
                
                .fullScreenCover(isPresented: $cardLoadingModel.isAnimationDone) {
                    CardMenuView()
                }
            }
        }
    }
}

#Preview {
    CardLoadingView()
}

