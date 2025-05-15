import SwiftUI
import SpriteKit

struct SpiderCard {
    let name: String
    let suit: String
    let rank: Int
    var isFaceUp: Bool
    var node: SKSpriteNode?
}

class SpiderGameData: ObservableObject {
    @Published var isPause = false
    @Published var isRestart = false
    @Published var isWin = false
    @Published var isInfo = false
    @Published var isHintShop = false
    @Published var scene = SKScene()
}

class SpiderGameSpriteKit: SKScene, SKPhysicsContactDelegate {
    var game: SpiderGameData?
    var deck: [String] = []
    var currentCardIndex = 0
    var columns: [[SpiderCard]] = Array(repeating: [], count: 10)
    var selectedCards: [SpiderCard] = []
    var additinalCards: [SKSpriteNode] = []
    var selectedNodes: [SKSpriteNode] = []
    var originalPositions: [CGPoint] = []
    var touchOffset: CGPoint = .zero
    var isDragging = false
    var remainingDeals = 5
    var countHint: SKLabelNode!
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        size = UIScreen.main.bounds.size
        createMainNode()
        createTappedNode()
        createCards()
        createCardColoda()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, let touch = touches.first else { return }
        let location = touch.location(in: self)
        for (i, node) in selectedNodes.enumerated() {
            let newPosition = CGPoint(
                x: location.x - touchOffset.x,
                y: location.y - touchOffset.y - CGFloat(i) * 10
            )
            node.position = newPosition
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging else { return }
        isDragging = false
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let targetColumnIndex = findColumnIndex(at: location) {
            if canPlaceSequence(selectedCards, onColumn: targetColumnIndex) {
                if let fromColumn = findColumnOfCard(selectedCards[0]) {
                    moveSequenceToColumn(selectedCards, fromColumn: fromColumn, toColumn: targetColumnIndex)
                    renderColumns()
                    checkAndRemoveCompletedSequences()
                    checkForWin()
                }
            } else {
                for (node, pos) in zip(selectedNodes, originalPositions) {
                    node.run(SKAction.move(to: pos, duration: 0.2))
                }
            }
        } else {
            for (node, pos) in zip(selectedNodes, originalPositions) {
                node.run(SKAction.move(to: pos, duration: 0.2))
            }
        }
        selectedCards.removeAll()
        selectedNodes.removeAll()
        originalPositions.removeAll()
    }
    
    func restartGame() {
        deck.removeAll()
        currentCardIndex = 0
        columns = Array(repeating: [], count: 10)
        selectedCards.removeAll()
        additinalCards.forEach { $0.removeFromParent() }
        additinalCards.removeAll()
        remainingDeals = 5
        game?.isWin = false

        removeAllChildren()

        createMainNode()
        createTappedNode()
        createCards()
        createCardColoda()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
         let location = touch.location(in: self)
        let touchedNodes = nodes(at: location).compactMap { $0 as? SKSpriteNode }

        if let deckNode = touchedNodes.first(where: { $0.name == "dealDeck" }) {
             animateDealNewRow(from: deckNode)
             return
         }
        
        if let _ = touchedNodes.first(where: { $0.name == "hint" || $0.name == "hintBack" }) {
            if UserDefaultsManager.defaults.integer(forKey: Keys.hintCount.rawValue) > 0 {
                if let hint = findHintMove() {
                    highlightHint(fromColumn: hint.fromColumn, fromIndex: hint.fromIndex, toColumn: hint.toColumn)
                    UserDefaultsManager().useBonus(key: Keys.hintCount.rawValue)
                    
                    countHint.attributedText = NSAttributedString(string: "\(UserDefaultsManager.defaults.integer(forKey: Keys.hintCount.rawValue))", attributes: [
                        NSAttributedString.Key.font: UIFont(name: "Gidugu", size: 24)!,
                        NSAttributedString.Key.foregroundColor: UIColor.white,
                        NSAttributedString.Key.strokeColor: UIColor(red: 255/255, green: 245/255, blue: 0/255, alpha: 1),
                        NSAttributedString.Key.strokeWidth: -4.5
                    ])
                }
            } else {
                game?.isHintShop = true
            }
        }
        
        if let _ = touchedNodes.first(where: { $0.name == "pause"}) {
            game?.isPause = true
        }
        
        if let _ = touchedNodes.first(where: { $0.name == "info" || $0.name == "infoBack" }) {
            game?.isInfo = true
        }
        
        if let _ = touchedNodes.first(where: { $0.name == "restart" || $0.name == "restartBack" }) {
            restartGame()
        }
        
        guard !isDragging  else { return }
        guard let cardNode = touchedNodes.first(where: { $0.name == "card" }) else { return }
        guard let (columnIndex, cardIndex) = findCardInColumns(byNode: cardNode) else { return }
        let column = columns[columnIndex]
        let card = column[cardIndex]
        guard card.isFaceUp else { return }
        let sequence = Array(column[cardIndex...])
        guard isValidDescendingSequence(sequence) else { return }

     
        
        selectedCards = sequence
        selectedNodes = sequence.compactMap { $0.node }
        originalPositions = selectedNodes.map { $0.position }
        touchOffset = CGPoint(x: location.x - cardNode.position.x, y: location.y - cardNode.position.y)
        isDragging = true
        for node in selectedNodes {
            node.zPosition = 1000
        }
    }
    
    func createTappedNode() {
        //MARK: - pause
        let pause = SKSpriteNode(imageNamed: "pauseGame")
        pause.size = CGSize(width: 80, height: 100)
        pause.name = "pause"
        pause.position = CGPoint(x: size.width / 10, y: size.height / 1.2)
        addChild(pause)
        
        //MARK: - info
        let infoBack = SKSpriteNode(imageNamed: "backBtnGame")
        infoBack.size = CGSize(width: 80, height: 80)
        infoBack.name = "infoBack"
        infoBack.position = CGPoint(x: size.width / 1.16, y: size.height / 1.16)
        addChild(infoBack)

        let info = SKSpriteNode(imageNamed: "infoGame")
        info.size = CGSize(width: 30, height: 50)
        info.name = "info"
        info.position = CGPoint(x: 0, y: 0)
        infoBack.addChild(info)

        let infoLabel = SKSpriteNode(imageNamed: "infoLabel")
        infoLabel.size = CGSize(width: 45, height: 14)
        infoLabel.position = CGPoint(x: 0, y: -50)
        infoBack.addChild(infoLabel)

        
        //MARK: - restart
        let restartBack = SKSpriteNode(imageNamed: "backBtnGame")
        restartBack.size = CGSize(width: 80, height: 80)
        restartBack.name = "restartBack"
        restartBack.position = CGPoint(x: size.width / 10, y: size.height / 5.5)
        addChild(restartBack)

        let restart = SKSpriteNode(imageNamed: "retry")
        restart.size = CGSize(width: 40, height: 40)
        restart.name = "restart"
        restart.position = CGPoint(x: 0, y: 0)
        restartBack.addChild(restart)

        let restartLabel = SKSpriteNode(imageNamed: "restartLabel")
        restartLabel.size = CGSize(width: 75, height: 15)
        restartLabel.position = CGPoint(x: 0, y: -50)
        restartBack.addChild(restartLabel)

        
        //MARK: - hint
        let hintBack = SKSpriteNode(imageNamed: "backBtnGame")
        hintBack.size = CGSize(width: 80, height: 80)
        hintBack.name = "hintBack"
        hintBack.position = CGPoint(x: size.width / 1.16, y: size.height / 5.5)
        addChild(hintBack)

        let hint = SKSpriteNode(imageNamed: "hint")
        hint.size = CGSize(width: 25, height: 35)
        hint.name = "hint"
        hint.position = CGPoint(x: 0, y: 0)
        hintBack.addChild(hint)

        let backForCountHint = SKSpriteNode(imageNamed: "backForCount")
        backForCountHint.size = CGSize(width: 35, height: 35)
        backForCountHint.position = CGPoint(x: -20, y: -30)
        hintBack.addChild(backForCountHint)

        countHint = SKLabelNode(fontNamed: "Gidugu")
        countHint.attributedText = NSAttributedString(
            string: "\(UserDefaultsManager.defaults.integer(forKey: Keys.hintCount.rawValue))",
            attributes: [
                NSAttributedString.Key.font: UIFont(name: "Gidugu", size: 24)!,
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.strokeColor: UIColor(red: 255/255, green: 245/255, blue: 0/255, alpha: 1),
                NSAttributedString.Key.strokeWidth: -4.5
            ]
        )
        countHint.position = CGPoint(x: -20, y: -40)
        hintBack.addChild(countHint)

        let hintLabel = SKSpriteNode(imageNamed: "hintLabel")
        hintLabel.size = CGSize(width: 55, height: 15)
        hintLabel.position = CGPoint(x: 0, y: -60)
        hintBack.addChild(hintLabel)
    }
}

struct CardSpiderGameView: View {
    @StateObject var cardSpiderGameModel =  CardSpiderGameViewModel()
    @StateObject var gameModel = SpiderGameData()
    
    var body: some View {
        ZStack {
            SpriteView(scene: cardSpiderGameModel.createGameScene(gameData: gameModel))
                .ignoresSafeArea()
                .navigationBarBackButtonHidden(true)
            
            if gameModel.isWin {
                CardWinView()
                    .onAppear() {
                        UserDefaultsManager().completeLevel()
                    }
            }
            
            if gameModel.isPause {
                CardPauseView(isPause: $gameModel.isPause)
            }
            
            if gameModel.isInfo {
                CardInfoView(caseInfo: .first, isInfo: $gameModel.isInfo)
            }
            
            if gameModel.isHintShop {
                CardShopHintView(isShow: $gameModel.isHintShop)
            }
        }
    }
}

#Preview {
    CardSpiderGameView()
}

