import SwiftUI

class CardSpiderGameViewModel: ObservableObject {
    let contact = CardSpiderGameModel()

    func createGameScene(gameData: SpiderGameData) -> SpiderGameSpriteKit {
        let scene = SpiderGameSpriteKit()
        scene.game  = gameData
        return scene
    }
}
