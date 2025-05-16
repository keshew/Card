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
        "\(UserDefaultsManager().getSelectedShopItem()?.name ?? "")tiles": [],
        "\(UserDefaultsManager().getSelectedShopItem()?.name ?? "")pickes": [],
        "\(UserDefaultsManager().getSelectedShopItem()?.name ?? "")heats": [],
        "\(UserDefaultsManager().getSelectedShopItem()?.name ?? "")clovers": []
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        size = UIScreen.main.bounds.size
        createMainNode()
        createTappedNode()
        createCards()
        createFourCard()
        createAdditionalColoda()
        NotificationCenter.default.addObserver(self, selector: #selector(updateHintAndUndoLabels), name: .updateHintAndUndoLabels, object: nil)
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let card = selectedCard else { return }
        let location = touch.location(in: self)
        card.node?.position = location
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
    
    @objc func updateHintAndUndoLabels() {
        countHint.attributedText = NSAttributedString(
            string: "\(UserDefaultsManager.defaults.integer(forKey: Keys.hintCount.rawValue))",
            attributes: [
                .font: UIFont(name: "Gidugu", size: 24)!,
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor(red: 255/255, green: 245/255, blue: 0/255, alpha: 1),
                .strokeWidth: -4.5
            ]
        )
        countUndo.attributedText = NSAttributedString(
            string: "\(UserDefaultsManager.defaults.integer(forKey: Keys.undoCount.rawValue))",
            attributes: [
                .font: UIFont(name: "Gidugu", size: 24)!,
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor(red: 255/255, green: 245/255, blue: 0/255, alpha: 1),
                .strokeWidth: -4.5
            ]
        )
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
                .onChange(of: gameModel.isHintShop) { newValue in
                    if !newValue {
                        NotificationCenter.default.post(name: .updateHintAndUndoLabels, object: nil)
                    }
                }
                .onChange(of: gameModel.isUndoShop) { newValue in
                    if !newValue {
                        NotificationCenter.default.post(name: .updateHintAndUndoLabels, object: nil)
                    }
                }
            
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

extension Notification.Name {
    static let updateHintAndUndoLabels = Notification.Name("updateHintAndUndoLabels")
}
