import SwiftUI

class CardAgnesGameViewModel: ObservableObject {
    let contact = CardAgnesGameModel()

    func createGameScene(gameData: AgnesGameData) -> AgnesGameSpriteKit {
        let scene = AgnesGameSpriteKit()
        scene.game  = gameData
        return scene
    }
}
