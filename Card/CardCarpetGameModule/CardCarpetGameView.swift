import SwiftUI
import SpriteKit

class CarpetGameData: ObservableObject {
    @Published var isPause = false
    @Published var isRestart = false
    @Published var isWin = false
    @Published var isInfo = false
    @Published var scene = SKScene()
    @Published var isHintShop = false
    @Published var isUndoShop = false
}

struct CarpetGameState {
    var columns: [[CarpetCard]]
    var freeCells: [CarpetCard?]
    var foundationPiles: [[CarpetCard]]
    var wasteCards: [CarpetCard]
    var currentNewCard: CarpetCard?
}

struct CarpetCard {
    let name: String
    let suit: String
    let rank: Int
    var isFaceUp: Bool
    var node: SKSpriteNode?
}

class CarpetGameSpriteKit: SKScene, SKPhysicsContactDelegate {
    var game: CarpetGameData?
    var columns: [[CarpetCard]] = Array(repeating: [], count: 8)
    var deck: [String] = []
    var currentCardIndex = 0
    var additinalCards: [CarpetCard] = []
    var selectedCard: CarpetCard?
    var selectedCardOriginalPosition: CGPoint?
    var selectedCardColumnIndex: Int?
    var selectedCardRowIndex: Int?
    var gameStatesStack: [CarpetGameState] = []
    var foundations: [String: [CarpetCard]] = [
        "hearts": [],
        "diamonds": [],
        "clubs": [],
        "spades": []
    ]
    var freeCells: [CarpetCard?] = Array(repeating: nil, count: 4)
    var freeCellNodes: [SKSpriteNode] = []
    var newCardNode: SKSpriteNode?
    var foundationPiles: [[CarpetCard]] = Array(repeating: [], count: 4)
    var currentNewCard: CarpetCard? = nil
    var foundationNodes: [SKSpriteNode] = []
    var stockCards: [CarpetCard] = []
    var wasteCards: [CarpetCard] = []
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
        createFourCard2()
    }
    
    func saveGameState() {
        let state = CarpetGameState(
            columns: columns,
            freeCells: freeCells,
            foundationPiles: foundationPiles,
            wasteCards: wasteCards,
            currentNewCard: currentNewCard
        )
        gameStatesStack.append(state)
    }
    
    func undoMove() {
        guard !gameStatesStack.isEmpty else { return }
        let lastState = gameStatesStack.removeLast()
        
        columns = lastState.columns
        freeCells = lastState.freeCells
        foundationPiles = lastState.foundationPiles
        wasteCards = lastState.wasteCards
        currentNewCard = lastState.currentNewCard
        
        removeAllCards()
        
        renderColumns()
        renderFoundations()
        
        if let card = currentNewCard, let node = card.node {
            addChild(node)
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
        foundationPiles = Array(repeating: [], count: 8)
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
        renderFoundations()
        renderColumns()
        createFourCard()
        createFourCard2()
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
                undoMove()
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
            return
        }
        
        for (_, cardOpt) in freeCells.enumerated() {
            if let card = cardOpt, let node = card.node, node.contains(location) {
                selectedCard = card
                selectedCardOriginalPosition = node.position
                selectedCardColumnIndex = nil
                selectedCardRowIndex = nil
                node.zPosition = 200
                return
            }
        }
        
        for (colIdx, column) in columns.enumerated() {
            if let lastCard = column.last, lastCard.isFaceUp, let node = lastCard.node, node.contains(location) {
                selectedCard = lastCard
                selectedCardOriginalPosition = node.position
                selectedCardColumnIndex = colIdx
                selectedCardRowIndex = column.count - 1
                node.zPosition = 200
                return
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
    }
    
    func textureName(for card: CarpetCard) -> String {
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
    
    func showHint() {
        removeHintHighlight()
        
        for (colIdx, column) in columns.enumerated() {
            if let card = column.last, card.isFaceUp {
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
        
        for cardOpt in freeCells {
            if let card = cardOpt {
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
    
    
    func highlightCard(_ card: CarpetCard) {
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let selectedCard = selectedCard, let node = selectedCard.node else { return }
        let location = touch.location(in: self)
        
        for (index, freeCellNode) in freeCellNodes.enumerated() {
            if freeCellNode.contains(location) {
                if canPlaceOnFreeCell(card: selectedCard, cellIndex: index) {
                    moveCardToFreeCell(card: selectedCard, cellIndex: index)
                    self.selectedCard = nil
                    return
                }
            }
        }
        
        for foundationIndex in 0..<4 {
            let foundationNode = foundationNodes[foundationIndex]
            if foundationNode.contains(location) {
                if canPlaceOnFoundation(card: selectedCard, foundationIndex: foundationIndex) {
                    moveCardToFoundation(card: selectedCard, foundationIndex: foundationIndex)
                    self.selectedCard = nil
                    return
                }
            }
        }
        
        for (colIdx, column) in columns.enumerated() {
            if let lastCard = column.last, let lastNode = lastCard.node {
                if lastNode.contains(location) || node.contains(location) {
                    if canMove(card: selectedCard, toColumn: colIdx) {
                        moveCardToColumn(card: selectedCard, toColumn: colIdx)
                        self.selectedCard = nil
                        return
                    }
                }
            } else {
                let columnX = size.width / 4 + CGFloat(colIdx) * (45 + 10)
                let columnY = size.height / 1.8
                let columnRect = CGRect(x: columnX - 22.5, y: columnY - 32.5, width: 45, height: 65)
                if columnRect.contains(location) {
                    moveCardToColumn(card: selectedCard, toColumn: colIdx)
                    self.selectedCard = nil
                    return
                }
            }
        }
        
        if let originalPos = selectedCardOriginalPosition {
            node.run(SKAction.move(to: originalPos, duration: 0.2))
        }
        self.selectedCard = nil
    }
    
    
    func moveCardToFreeCell(card: CarpetCard, cellIndex: Int) {
        saveGameState()
        removeCardFromCurrentPlace(card: card)
        
        freeCells[cellIndex] = card
        
        if let node = card.node {
            let targetNode = freeCellNodes[cellIndex]
            node.position = targetNode.position
            node.zPosition = 150
        }
    }
    
    func moveCardToFoundation(card: CarpetCard, foundationIndex: Int) {
        removeCardFromCurrentPlace(card: card)
        foundationPiles[foundationIndex].append(card)
        if let node = card.node {
            let foundationNode = foundationNodes[foundationIndex]
            node.position = foundationNode.position
            node.zPosition = 100
        }
        checkWin()
    }
    
    
    
    func moveCardToColumn(card: CarpetCard, toColumn: Int) {
        saveGameState()
        
        removeCardFromCurrentPlace(card: card)
        columns[toColumn].append(card)
        if let node = card.node {
            let startX = size.width / 4
            let cardWidth: CGFloat = 45
            let cardSpacingY: CGFloat = 10
            let xPos = startX + CGFloat(toColumn) * (cardWidth + 10)
            let yPos = size.height / 1.8 - CGFloat(columns[toColumn].count - 1) * cardSpacingY
            node.position = CGPoint(x: xPos, y: yPos)
            node.zPosition = CGFloat(columns[toColumn].count)
        }
        flipTopCardIfNeeded(inColumn: toColumn)
    }
    
    func removeCardFromCurrentPlace(card: CarpetCard) {
        if let index = freeCells.firstIndex(where: { $0?.name == card.name }) {
            freeCells[index] = nil
        }
        for colIdx in 0..<columns.count {
            if let rowIdx = columns[colIdx].firstIndex(where: { $0.name == card.name }) {
                columns[colIdx].remove(at: rowIdx)
                flipTopCardIfNeeded(inColumn: colIdx)
                break
            }
        }
        for foundationIdx in 0..<foundationPiles.count {
            if let idx = foundationPiles[foundationIdx].firstIndex(where: { $0.name == card.name }) {
                foundationPiles[foundationIdx].remove(at: idx)
                break
            }
        }
    }
    
    func canPlaceOnFreeCell(card: CarpetCard, cellIndex: Int) -> Bool {
        return freeCells[cellIndex] == nil
    }
    
    func handleTouchOnFreeFoundation(at index: Int) {
        print("Touched free foundation at index \(index)")
    }
    
    func handleTouchOnFoundation(at index: Int) {
        print("Touched foundation at index \(index)")
    }
    
    func handleTouchOnOtherNodes(at location: CGPoint) {
        print("Touched other node at \(location)")
    }
    
    func checkWin() {
        if foundationPiles[0...3].allSatisfy({ $0.count == 13 }) {
            game?.isWin = true
        }
    }
    
    func maxMovableCards() -> Int {
        let freeCellsCount = freeCells.filter { $0 == nil }.count
        let emptyColumnsCount = columns.filter { $0.isEmpty }.count
        return (freeCellsCount + 1) * Int(pow(2.0, Double(emptyColumnsCount)))
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
            if child.name == "card" || child.name == "wasteCard" || child.name == "newCard" {
                child.removeFromParent()
            }
        }
    }
    
    
    func canPlaceOnFreeFoundation(card: CarpetCard, foundationIndex: Int) -> Bool {
        let pile = foundationPiles[foundationIndex]
        return pile.isEmpty
    }
    
    func canPlaceOnFoundation(card: CarpetCard, foundationIndex: Int) -> Bool {
        let pile = foundationPiles[foundationIndex]
        if pile.isEmpty {
            return card.rank == 1
        } else if let lastCard = pile.last {
            return lastCard.suit == card.suit && lastCard.rank + 1 == card.rank
        }
        return false
    }
    
    func isRed(suit: String) -> Bool {
        return suit == "hearts" || suit == "diamonds"
    }
    
    func canMove(card: CarpetCard, toColumn: Int) -> Bool {
        let targetColumn = columns[toColumn]
        if let last = targetColumn.last {
            return isRed(suit: last.suit) != isRed(suit: card.suit) && last.rank == card.rank + 1
        } else {
            return true
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
}

struct CardCarpetGameView: View {
    @StateObject var cardCarpetGameModel =  CardCarpetGameViewModel()
    @StateObject var gameModel = CarpetGameData()
    
    var body: some View {
        ZStack {
            SpriteView(scene: cardCarpetGameModel.createGameScene(gameData: gameModel))
                .ignoresSafeArea()
                .navigationBarBackButtonHidden(true)
            
            if gameModel.isWin {
                CardWinView()
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
    CardCarpetGameView()
}

