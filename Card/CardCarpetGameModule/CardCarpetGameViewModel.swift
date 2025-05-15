import SwiftUI

class CardCarpetGameViewModel: ObservableObject {
    let contact = CardCarpetGameModel()

    func createGameScene(gameData: CarpetGameData) -> CarpetGameSpriteKit {
        let scene = CarpetGameSpriteKit()
        scene.game  = gameData
        return scene
    }
}
