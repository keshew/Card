import SwiftUI

extension Text {
    func CustomFont(size: CGFloat,
                    color: LinearGradient = LinearGradient(colors: [Color(red: 255/255, green: 245/255, blue: 0/255), Color(red: 255/255, green: 184/255, blue: 0/255)], startPoint: .top, endPoint: .bottom),
                    colorOutline: Color = .white,
                    width: CGFloat = 0.7) -> some View {
        self.font(.custom("Gidugu", size: size))
            .foregroundStyle(color)
            .outlineText(color: colorOutline, width: width)
    }
}
