import SwiftUI
import SpriteKit

class AgnesGameData: ObservableObject {
    @Published var isPause = false
    @Published var isRestart = false
    @Published var isWin = false
    @Published var isInfo = false
    @Published var scene = SKScene()
    @Published var isHintShop = false
    @Published var isUndoShop = false
}

struct SolitaireCard {
    let name: String
    let suit: String
    let rank: Int
    var isFaceUp: Bool
    var node: SKSpriteNode?
}

struct GameState {
    var columns: [[SolitaireCard]]
    var foundationPiles: [[SolitaireCard]]
    var stockCards: [SolitaireCard]
    var wasteCards: [SolitaireCard]
    var currentNewCard: SolitaireCard?
}


class AgnesGameSpriteKit: SKScene, SKPhysicsContactDelegate {
    var game: AgnesGameData?
    var columns: [[SolitaireCard]] = Array(repeating: [], count: 7)
    var deck: [String] = []
    var currentCardIndex = 0
    var additinalCards: [SolitaireCard] = []
    var selectedCard: SolitaireCard?
    var selectedCardOriginalPosition: CGPoint?
    var selectedCardColumnIndex: Int?
    var selectedCardRowIndex: Int?
    var foundations: [String: [SolitaireCard]] = [
        "hearts": [],
        "diamonds": [],
        "clubs": [],
        "spades": []
    ]
    var gameStatesStack: [GameState] = []
    var newCardNode: SKSpriteNode?
    var foundationPiles: [[SolitaireCard]] = Array(repeating: [], count: 4)
    var currentNewCard: SolitaireCard? = nil
    var foundationNodes: [SKSpriteNode] = []
    var stockCards: [SolitaireCard] = []
    var wasteCards: [SolitaireCard] = []
    var countUndo: SKLabelNode!
    var countHint: SKLabelNode!
    
    func createMainNode() {
        let gameBackground = SKSpriteNode(imageNamed: "bg")
        gameBackground.size = CGSize(width: size.width, height: size.height)
        gameBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameBackground)
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        size = UIScreen.main.bounds.size
        createMainNode()
        createTappedNode()
        createCards()
        createFourCard()
        createAdditionalColoda()
    }
    
    func saveCurrentState() {
        let state = GameState(
            columns: columns,
            foundationPiles: foundationPiles,
            stockCards: stockCards,
            wasteCards: wasteCards,
            currentNewCard: currentNewCard
        )
        gameStatesStack.append(state)
        
        if gameStatesStack.count > 50 {
            gameStatesStack.removeFirst()
        }
    }
    
    func undoLastMove() {
        guard gameStatesStack.count > 1 else { return }
        
        gameStatesStack.removeLast()
        
        if let prevState = gameStatesStack.last {
            columns = prevState.columns
            foundationPiles = prevState.foundationPiles
            stockCards = prevState.stockCards
            wasteCards = prevState.wasteCards
            currentNewCard = prevState.currentNewCard
            
            removeAllCards()
            renderColumns()
            renderFoundations()
            
            if let card = currentNewCard, let node = card.node {
                node.position = CGPoint(x: size.width / 1.85, y: size.height / 9)
                addChild(node)
            }
        }
    }
    
    
    func restartGame() {
        deck.removeAll()
        currentCardIndex = 0
        columns = Array(repeating: [], count: 7)
        additinalCards.forEach { $0.node?.removeFromParent() }
        additinalCards.removeAll()
        wasteCards.forEach { $0.node?.removeFromParent() }
        wasteCards.removeAll()
        foundationPiles = Array(repeating: [], count: 4)
        selectedCard = nil
        selectedCardOriginalPosition = nil
        selectedCardColumnIndex = nil
        selectedCardRowIndex = nil
        currentNewCard?.node?.removeFromParent()
        currentNewCard = nil
        game?.isWin = false
        
        removeAllChildren()
        
        
        createMainNode()
        createTappedNode()
        createCards()
        createAdditionalColoda()
        renderFoundations()
        renderColumns()
        createFourCard()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        if let _ = nodes.first(where: { $0.name == "hint" || $0.name == "hintBack" }) {
            if UserDefaultsManager.defaults.integer(forKey: Keys.hintCount.rawValue) > 0 {
                showHint()
                UserDefaultsManager().useBonus(key: Keys.hintCount.rawValue)
                countHint.attributedText = NSAttributedString(string: "\(UserDefaultsManager.defaults.integer(forKey: Keys.hintCount.rawValue))", attributes: [
                    NSAttributedString.Key.font: UIFont(name: "Gidugu", size: 24)!,
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.strokeColor: UIColor(red: 255/255, green: 245/255, blue: 0/255, alpha: 1),
                    NSAttributedString.Key.strokeWidth: -4.5
                ])
            } else {
                game?.isHintShop = true
            }
        }
        
        if let _ = nodes.first(where: { $0.name == "pause"}) {
            game?.isPause = true
        }
        
        if let _ = nodes.first(where: { $0.name == "info" || $0.name == "infoBack" }) {
            game?.isInfo = true
        }
        
        if let _ = nodes.first(where: { $0.name == "restart" || $0.name == "restartBack" }) {
            restartGame()
        }
        
        if let _ = nodes.first(where: { $0.name == "undo" || $0.name == "undoBack" }) {
            if UserDefaultsManager.defaults.integer(forKey: Keys.undoCount.rawValue) > 0 {
                undoLastMove()
                UserDefaultsManager().useBonus(key: Keys.undoCount.rawValue)
                countUndo.attributedText = NSAttributedString(string: "\(UserDefaultsManager.defaults.integer(forKey: Keys.undoCount.rawValue))", attributes: [
                    NSAttributedString.Key.font: UIFont(name: "Gidugu", size: 24)!,
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.strokeColor: UIColor(red: 255/255, green: 245/255, blue: 0/255, alpha: 1),
                    NSAttributedString.Key.strokeWidth: -4.5
                ])
            } else {
                game?.isUndoShop = true
            }
        }
        
        if let card = currentNewCard, let node = card.node, node.contains(location) {
            selectedCard = card
            selectedCardOriginalPosition = node.position
            selectedCardColumnIndex = nil
            selectedCardRowIndex = nil
            node.zPosition = 200
            return
        }
        
        for (colIdx, column) in columns.enumerated() {
            if let rowIdx = column.lastIndex(where: { $0.isFaceUp && $0.node?.contains(location) == true }) {
                selectedCard = columns[colIdx][rowIdx]
                selectedCardOriginalPosition = selectedCard?.node?.position
                selectedCardColumnIndex = colIdx
                selectedCardRowIndex = rowIdx
                selectedCard?.node?.zPosition = 200
                break
            }
        }
        
        if let _ = nodes.first(where: { $0.name == "dealDeck" }) {
            dealCardFromAdditionalDeck()
        }
    }
    
    
    func textureName(for card: SolitaireCard) -> String {
        let suitName = card.suit.lowercased()
        switch card.rank {
        case 1:
            return "\(suitName)A"
        case 11:
            return "\(suitName)Jack"
        case 12:
            return "\(suitName)Queen"
        case 13:
            return "\(suitName)King"
        default:
            return "\(suitName)\(card.rank)"
        }
    }
    
    func dealCardFromAdditionalDeck() {
        guard !additinalCards.isEmpty else { return }
        saveCurrentState()
        
        var card = additinalCards.removeLast()
        card.node?.removeFromParent()
        
        let texName = textureName(for: card)
        print(texName)
        let node = SKSpriteNode(imageNamed: texName)
        node.size = CGSize(width: 45, height: 65)
        node.position = CGPoint(x: size.width / 1.85, y: size.height / 9)
        node.name = "newCard"
        node.zPosition = 100
        addChild(node)
        card.node = node
        card.isFaceUp = true
        currentNewCard = card
        
        for child in children {
            if child.name == "newCard" && child != node {
                child.removeFromParent()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let card = selectedCard else { return }
        let location = touch.location(in: self)
        card.node?.position = location
    }
    
    func highlightCard(_ card: SolitaireCard) {
        guard let node = card.node else { return }
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.15)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeat(pulse, count: 10)
        
        node.run(repeatPulse, withKey: "hintHighlight")
        
        let wait = SKAction.wait(forDuration: 3.0)
        let reset = SKAction.run {
            node.setScale(1.0)
            node.removeAction(forKey: "hintHighlight")
        }
        node.run(SKAction.sequence([wait, reset]))
    }
    
    func removeHintHighlight() {
        for column in columns {
            for card in column {
                card.node?.removeAction(forKey: "hintHighlight")
                card.node?.setScale(1.0)
            }
        }
        currentNewCard?.node?.removeAction(forKey: "hintHighlight")
        currentNewCard?.node?.setScale(1.0)
    }
    
    
    func showHint() {
        removeHintHighlight()
        
        for (colIdx, column) in columns.enumerated() {
            for (_, card) in column.enumerated() where card.isFaceUp {
                for targetColIdx in 0..<columns.count where targetColIdx != colIdx {
                    if canMove(card: card, toColumn: targetColIdx) {
                        highlightCard(card)
                        return
                    }
                }
                for foundationIndex in 0..<foundationPiles.count {
                    if canPlaceOnFoundation(card: card, foundationIndex: foundationIndex) {
                        highlightCard(card)
                        return
                    }
                }
            }
        }
        
        if let card = currentNewCard {
            for foundationIndex in 0..<foundationPiles.count {
                if canPlaceOnFoundation(card: card, foundationIndex: foundationIndex) {
                    highlightCard(card)
                    return
                }
            }
            for targetColIdx in 0..<columns.count {
                if canMove(card: card, toColumn: targetColIdx) {
                    highlightCard(card)
                    return
                }
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let card = selectedCard else { return }
        let location = touches.first!.location(in: self)
        
        saveCurrentState()
        
        if selectedCardColumnIndex == nil {
            for (foundationIndex, foundationNode) in foundationNodes.enumerated() {
                if foundationNode.contains(location) && canPlaceOnFoundation(card: card, foundationIndex: foundationIndex) {
                    foundationPiles[foundationIndex].append(card)
                    card.node?.removeFromParent()
                    renderFoundations()
                    currentNewCard = nil
                    selectedCard = nil
                    return
                }
            }
            for i in 0..<columns.count {
                let columnX = size.width / 4 + CGFloat(i) * (45 + 10)
                if abs(location.x - columnX) < 45 && canMove(card: card, toColumn: i) {
                    columns[i].append(card)
                    card.node?.removeFromParent()
                    removeAllCards()
                    renderColumns()
                    currentNewCard = nil
                    selectedCard = nil
                    return
                }
            }
            card.node?.position = selectedCardOriginalPosition ?? .zero
            selectedCard = nil
            return
        }
        
        if let colIdx = selectedCardColumnIndex, let rowIdx = selectedCardRowIndex {
            for (foundationIndex, foundationNode) in foundationNodes.enumerated() {
                if foundationNode.contains(location) && canPlaceOnFoundation(card: card, foundationIndex: foundationIndex) {
                    foundationPiles[foundationIndex].append(card)
                    columns[colIdx].remove(at: rowIdx)
                    card.node?.removeFromParent()
                    renderFoundations()
                    flipTopCardIfNeeded(inColumn: colIdx)
                    removeAllCards()
                    renderColumns()
                    selectedCard = nil
                    selectedCardColumnIndex = nil
                    selectedCardRowIndex = nil
                    return
                }
            }
            for i in 0..<columns.count {
                let columnX = size.width / 4 + CGFloat(i) * (45 + 10)
                if abs(location.x - columnX) < 45 && canMove(card: card, toColumn: i) {
                    columns[i].append(card)
                    columns[colIdx].remove(at: rowIdx)
                    card.node?.removeFromParent()
                    flipTopCardIfNeeded(inColumn: colIdx)
                    removeAllCards()
                    renderColumns()
                    selectedCard = nil
                    selectedCardColumnIndex = nil
                    selectedCardRowIndex = nil
                    return
                }
            }
            card.node?.position = selectedCardOriginalPosition ?? .zero
            selectedCard = nil
            selectedCardColumnIndex = nil
            selectedCardRowIndex = nil
            return
        }
        
        selectedCard = nil
        selectedCardOriginalPosition = nil
        selectedCardColumnIndex = nil
        selectedCardRowIndex = nil
    }
    
    
    func flipTopCardIfNeeded(inColumn colIdx: Int) {
        guard !columns[colIdx].isEmpty else { return }
        var topCard = columns[colIdx].last!
        if !topCard.isFaceUp {
            topCard.isFaceUp = true
            if let node = topCard.node {
                let texName = textureName(for: topCard)
                node.texture = SKTexture(imageNamed: texName)
            }
            columns[colIdx][columns[colIdx].count - 1] = topCard
        }
    }
    
    func removeAllCards() {
        for child in children {
            if child.name == "card" {
                child.removeFromParent()
            }
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
        
        let hintBack = SKSpriteNode(imageNamed: "backBtnGame")
        hintBack.size = CGSize(width: 80, height: 80)
        hintBack.name = "hintBack"
        hintBack.position = CGPoint(x: size.width / 1.32, y: size.height / 5.5)
        addChild(hintBack)

        let hint = SKSpriteNode(imageNamed: "hint")
        hint.size = CGSize(width: 25, height: 35)
        hint.name = "hint"
        hint.position = CGPoint(x: 0, y: 0)
        hintBack.addChild(hint)

        let backForCountHint = SKSpriteNode(imageNamed: "backForCount")
        backForCountHint.size = CGSize(width: 35, height: 35)
        backForCountHint.position = CGPoint(x: -25, y: -30)
        hintBack.addChild(backForCountHint)

        countHint = SKLabelNode(fontNamed: "Gidugu")
        countHint.attributedText = NSAttributedString(
            string: "\(UserDefaultsManager.defaults.integer(forKey: Keys.hintCount.rawValue))",
            attributes: [
                NSAttributedString.Key.font: UIFont(name: "Gidugu", size: 24)!,
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.strokeColor: UIColor(red: 255/255, green: 245/255, blue: 0/255, alpha: 1),
                NSAttributedString.Key.strokeWidth: -4.5
            ])
        countHint.position = CGPoint(x: -25, y: -38)
        hintBack.addChild(countHint)

        let hintLabel = SKSpriteNode(imageNamed: "hintLabel")
        hintLabel.size = CGSize(width: 55, height: 15)
        hintLabel.position = CGPoint(x: 0, y: -60)
        hintBack.addChild(hintLabel)

        let undoBack = SKSpriteNode(imageNamed: "backBtnGame")
        undoBack.size = CGSize(width: 80, height: 80)
        undoBack.name = "undoBack"
        undoBack.position = CGPoint(x: size.width / 1.16, y: size.height / 5.5)
        addChild(undoBack)

        let undo = SKSpriteNode(imageNamed: "undo")
        undo.size = CGSize(width: 35, height: 45)
        undo.name = "undo"
        undo.position = CGPoint(x: 0, y: 0)
        undoBack.addChild(undo)

        let backForCountUndo = SKSpriteNode(imageNamed: "backForCount")
        backForCountUndo.size = CGSize(width: 35, height: 35)
        backForCountUndo.position = CGPoint(x: -25, y: -30)
        undoBack.addChild(backForCountUndo)

        countUndo = SKLabelNode(fontNamed: "Gidugu")
        countUndo.attributedText = NSAttributedString(
            string: "\(UserDefaultsManager.defaults.integer(forKey: Keys.undoCount.rawValue))",
            attributes: [
                NSAttributedString.Key.font: UIFont(name: "Gidugu", size: 24)!,
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.strokeColor: UIColor(red: 255/255, green: 245/255, blue: 0/255, alpha: 1),
                NSAttributedString.Key.strokeWidth: -4.5
            ])
        countUndo.position = CGPoint(x: -25, y: -38)
        undoBack.addChild(countUndo)

        let undoLabel = SKSpriteNode(imageNamed: "undoLabel")
        undoLabel.size = CGSize(width: 55, height: 15)
        undoLabel.position = CGPoint(x: 0, y: -60)
        undoBack.addChild(undoLabel)

    }
    
    func canMove(card: SolitaireCard, toColumn: Int) -> Bool {
        let targetColumn = columns[toColumn]
        if let last = targetColumn.last, last.isFaceUp {
            return last.rank == card.rank + 1 && last.suit != card.suit
        } else if targetColumn.isEmpty {
            return card.rank == 13
        }
        return false
    }
}

struct CardAgnesGameView: View {
    @StateObject var cardAgnesGameModel =  CardAgnesGameViewModel()
    @StateObject var gameModel = AgnesGameData()
    
    var body: some View {
        ZStack {
            SpriteView(scene: cardAgnesGameModel.createGameScene(gameData: gameModel))
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
            
            if gameModel.isUndoShop {
                CardShopUndoView(isShow: $gameModel.isUndoShop)
            }
            
            if gameModel.isHintShop {
                CardShopHintView(isShow: $gameModel.isHintShop)
            }
        }
    }
}

#Preview {
    CardAgnesGameView()
}
