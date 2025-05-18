import SwiftUI
import SpriteKit

extension AgnesGameSpriteKit {
    
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
    
    func canMove(card: SolitaireCard, toColumn: Int) -> Bool {
        let targetColumn = columns[toColumn]
        if let last = targetColumn.last, last.isFaceUp {
            return last.rank == card.rank + 1 && last.suit != card.suit
        } else if targetColumn.isEmpty {
            return card.rank == 13
        }
        return false
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
        let node = SKSpriteNode(imageNamed: texName)
        node.size = CGSize(width: 45, height: 65)
        node.position = CGPoint(x: size.width / 1.85, y: size.height / 9)
        node.name = "newCard"
        node.zPosition = 100
        addChild(node)
        card.node = node
        card.isFaceUp = true
        currentNewCard = card

        dealtAdditionalCards.append(card)

        for child in children {
            if child.name == "newCard" && child != node {
                child.removeFromParent()
            }
        }
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
        if let view = self.view {
            let newScene = AgnesGameSpriteKit(size: self.size)
            newScene.game = self.game
            view.presentScene(newScene, transition: .fade(withDuration: 0))
        }
    }
    
    func createFourCard() {
        let selectedItem = UserDefaultsManager().getSelectedShopItem()
        
        let cardWidth: CGFloat = 45
        let cardHeight: CGFloat = 65
        let startX = size.width / 2
        let startY = size.height / 1.26
        
        for column in 0..<4 {
            let cardNode = SKSpriteNode(imageNamed: selectedItem?.backName ?? "spiderBackCard")
            cardNode.name = "foundationSlot"
            cardNode.size = CGSize(width: cardWidth, height: cardHeight)
            let xPos = startX + CGFloat(column) * 55
            let yPos = startY
            cardNode.position = CGPoint(x: xPos, y: yPos)
            addChild(cardNode)
            foundationNodes.append(cardNode)
        }
    }
    
    func renderFoundations() {
        let selectedItem = UserDefaultsManager().getSelectedShopItem()
        for i in 0..<foundationPiles.count {
            if let topCard = foundationPiles[i].last {
                let node = foundationNodes[i]
                let texName = textureName(for: topCard)
                node.texture = SKTexture(imageNamed: texName)
                node.size = CGSize(width: 45, height: 65)
            } else {
               
                foundationNodes[i].texture = SKTexture(imageNamed: selectedItem?.backName ?? "spiderBackCard")
            }
        }
    }

    func canPlaceOnFoundation(card: SolitaireCard, foundationIndex: Int) -> Bool {
        guard foundationIndex >= 0 && foundationIndex < foundationPiles.count else {
            return false
        }
        let pile = foundationPiles[foundationIndex]
        if pile.isEmpty {
            return card.rank == 1
        } else if let topCard = pile.last {
            return card.suit == topCard.suit && card.rank == topCard.rank + 1
        }
        return false
    }
    
    func createAdditionalColoda() {
        let selectedItem = UserDefaultsManager().getSelectedShopItem()
        
        let suits = ["\(selectedItem?.name ?? "")tiles", "\(selectedItem?.name ?? "")pickes", "\(selectedItem?.name ?? "")heats", "\(selectedItem?.name ?? "")clovers"]
        var allCards: [SolitaireCard] = []
        for suit in suits {
            for rank in 1...13 {
                let card = SolitaireCard(name: cardImageName(suit: suit, rank: rank), suit: suit, rank: rank, isFaceUp: false, node: nil)
                print(card.name)
                allCards.append(card)
            }
        }
        allCards.shuffle()
        let additional = allCards.prefix(24)
        
        for (i, card) in additional.enumerated() {
            let node = SKSpriteNode(imageNamed: selectedItem?.backName ?? "spiderBackCard")
            node.size = CGSize(width: 45, height: 65)
            node.position = CGPoint(x: size.width / 3 + (CGFloat(i) * 5), y: size.height / 9)
            node.name = "dealDeck"
            addChild(node)
            var cardCopy = card
            cardCopy.node = node
            additinalCards.append(cardCopy)
        }
        
        let newCardNode = SKSpriteNode(imageNamed: selectedItem?.backName ?? "spiderBackCard")
        newCardNode.size = CGSize(width: 45, height: 65)
        newCardNode.position = CGPoint(x: size.width / 1.85, y: size.height / 9)
        newCardNode.name = "newCard"
        addChild(newCardNode)
    }
    
    func cardImageName(suit: String, rank: Int) -> String {
        switch rank {
        case 1: return "\(suit)A"
        case 11: return "\(suit)Jack"
        case 12: return "\(suit)Queen"
        case 13: return "\(suit)King"
        default: return "\(suit)\(rank)"
        }
    }

    func createDeck() {
        deck = []
        let selectedItem = UserDefaultsManager().getSelectedShopItem()
        let suits = ["\(selectedItem?.name ?? "")tiles", "\(selectedItem?.name ?? "")pickes", "\(selectedItem?.name ?? "")heats", "\(selectedItem?.name ?? "")clovers"]
        let ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]
        for _ in 0..<1 {
            for suit in suits {
                for rank in ranks {
                    deck.append("\(suit)\(rank)")
                }
            }
        }
        deck.shuffle()
        currentCardIndex = 0
    }
    
    func createCards() {
        createDeck()
        columns = Array(repeating: [], count: 7)
        let stackCounts = [1,2,3,4,5,6,7]
        
        for column in 0..<7 {
            for row in 0..<stackCounts[column] {
                let isFaceUp = (row == stackCounts[column] - 1)
                if let cardName = getNextCard() {
                    let (suit, rank) = parseCardName(cardName)
                    let card = SolitaireCard(name: cardName, suit: suit, rank: rank, isFaceUp: isFaceUp, node: nil)
                    columns[column].append(card)
                }
            }
        }
        renderColumns()
    }
    
    func getNextCard() -> String? {
        guard currentCardIndex < deck.count else {
            return nil
        }
        let card = deck[currentCardIndex]
        currentCardIndex += 1
        return card
    }
    
    func parseCardName(_ name: String) -> (String, Int) {
        let selectedItem = UserDefaultsManager().getSelectedShopItem()
        let suits = ["\(selectedItem?.name ?? "")tiles", "\(selectedItem?.name ?? "")pickes", "\(selectedItem?.name ?? "")heats", "\(selectedItem?.name ?? "")clovers"]
        for suit in suits {
            if name.hasPrefix(suit) {
                let rankStr = name.replacingOccurrences(of: suit, with: "")
                let rank: Int
                switch rankStr {
                case "A": rank = 1
                case "Jack": rank = 11
                case "Queen": rank = 12
                case "King": rank = 13
                default: rank = Int(rankStr) ?? 0
                }
                return (suit, rank)
            }
        }
        return ("unknown", 0)
    }
    
    func renderColumns() {
        let selectedItem = UserDefaultsManager().getSelectedShopItem()
        let cardWidth: CGFloat = 45
        let cardHeight: CGFloat = 65
        let startX = size.width / 4
        let startY = size.height / 1.8
        let cardSpacingY: CGFloat = 10
        let cardSpacingX: CGFloat = cardWidth + 10
        
        for (columnIndex, column) in columns.enumerated() {
            for (rowIndex, card) in column.enumerated() {
                let textureName = card.isFaceUp ? card.name : selectedItem?.backName ?? "spiderBackCard"
                let cardNode = SKSpriteNode(imageNamed: textureName)
                cardNode.name = "card"
                cardNode.size = CGSize(width: cardWidth, height: cardHeight)
                let xPos = startX + CGFloat(columnIndex) * cardSpacingX
                let yPos = startY - CGFloat(rowIndex) * cardSpacingY
                cardNode.position = CGPoint(x: xPos, y: yPos)
                addChild(cardNode)
                columns[columnIndex][rowIndex].node = cardNode
            }
        }
    }
}
