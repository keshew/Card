import SwiftUI
import SpriteKit

extension SpiderGameSpriteKit {
    func createMainNode() {
        let gameBackground = SKSpriteNode(imageNamed: "bg")
        gameBackground.size = CGSize(width: size.width, height: size.height)
        gameBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameBackground)
    }
    

    
    func createDeck() {
        deck = []
        
        let selectedItem = UserDefaultsManager().getSelectedShopItem()
        
        let suits = ["\(selectedItem?.name ?? "")tiles", "\(selectedItem?.name ?? "")pickes", "\(selectedItem?.name ?? "")heats", "\(selectedItem?.name ?? "")clovers"]
        let ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]
        for _ in 0..<2 {
            for suit in suits {
                for rank in ranks {
                    deck.append("\(suit)\(rank)")
                }
            }
        }
        deck.shuffle()
        currentCardIndex = 0
    }
    
    func getNextCard() -> String? {
        guard currentCardIndex < deck.count else {
            return nil
        }
        let card = deck[currentCardIndex]
        currentCardIndex += 1
        return card
    }
    
    func createCards() {
        createDeck()
        columns = Array(repeating: [], count: 10)
        let stackCounts = [6,6,6,6,5,5,5,5,5,5]
        
        for column in 0..<10 {
            for row in 0..<stackCounts[column] {
                let isFaceUp = (row == stackCounts[column] - 1)
                if let cardName = getNextCard() {
                    let (suit, rank) = parseCardName(cardName)
                    let card = SpiderCard(name: cardName, suit: suit, rank: rank, isFaceUp: isFaceUp, node: nil)
                    columns[column].append(card)
                }
            }
        }
        renderColumns()
    }
    func renderColumns() {
        let selectedItem = UserDefaultsManager().getSelectedShopItem()
        removeAllCardsFromScene()
        let cardWidth: CGFloat = 45
        let cardHeight: CGFloat = 65
        let startX = size.width / 5
        let startY = size.height / 1.15
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
    
    func removeAllCardsFromScene() {
        self.children.filter { $0.name == "card" }.forEach { $0.removeFromParent() }
    }
    
    func createCardColoda() {
        let selectedItem = UserDefaultsManager().getSelectedShopItem()
        for i in 0..<50 {
            let card = SKSpriteNode(imageNamed: selectedItem?.backName ?? "spiderBackCard")
            card.size = CGSize(width: 45, height: 65)
            card.position = CGPoint(x: size.width / 5 + (CGFloat(i) * 5), y: size.height / 9)
            card.name = "dealDeck"
            addChild(card)
            additinalCards.append(card)
        }
    }
    
    func checkAndRemoveCompletedSequences() {
        for colIndex in 0..<columns.count {
            let column = columns[colIndex]
            if column.count >= 13 {
                let last13 = column.suffix(13)
                if isCompleteSuitSequence(Array(last13)) {
                    columns[colIndex].removeLast(13)
                    renderColumns()
                }
            }
        }
    }
    
    func isCompleteSuitSequence(_ cards: [SpiderCard]) -> Bool {
        guard cards.count == 13 else { return false }
        for i in 0..<12 {
            if cards[i].suit != cards[i+1].suit { return false }
            if cards[i].rank != cards[i+1].rank + 1 { return false }
            if !cards[i].isFaceUp || !cards[i+1].isFaceUp { return false }
        }
        return cards.first!.rank == 13 && cards.last!.rank == 1
    }
    
    func canDealNewRow() -> Bool {
        return columns.allSatisfy { !$0.isEmpty }
    }
    
    func dealNewRow() {
        guard canDealNewRow() else { return }
        for columnIndex in 0..<10 {
            if let cardName = getNextCard() {
                let (suit, rank) = parseCardName(cardName)
                let card = SpiderCard(name: cardName, suit: suit, rank: rank, isFaceUp: true, node: nil)
                columns[columnIndex].append(card)
            }
        }
        renderColumns()
    }
    
    func checkForWin() {
        let isWin = columns.allSatisfy { $0.isEmpty }
        if isWin {
            game?.isWin = true
        }
    }
    
    func animateDealNewRow(from deckNode: SKNode) {
        guard canDealNewRow(), remainingDeals > 0, (deck.count - currentCardIndex) >= 10 else { return }
        remainingDeals -= 1
        
        let cardsToRemove = min(10, additinalCards.count)
        for _ in 0..<cardsToRemove {
            if let cardNode = additinalCards.last {
                cardNode.removeFromParent()
                additinalCards.removeLast()
            }
        }
        
        if remainingDeals == 0 {
            deckNode.removeFromParent()
        }
        
        let cardWidth: CGFloat = 45
        let cardHeight: CGFloat = 65
        let startX = size.width / 5
        let startY = size.height / 1.15
        let cardSpacingX: CGFloat = cardWidth + 10
        
        for columnIndex in 0..<10 {
            guard let cardName = getNextCard() else { continue }
            let (suit, rank) = parseCardName(cardName)
            let card = SpiderCard(name: cardName, suit: suit, rank: rank, isFaceUp: true, node: nil)
            columns[columnIndex].append(card)
            
            let cardNode = SKSpriteNode(imageNamed: cardName)
            cardNode.size = CGSize(width: cardWidth, height: cardHeight)
            cardNode.position = deckNode.position
            cardNode.zPosition = 999
            addChild(cardNode)
            
            let yPos = startY - CGFloat(columns[columnIndex].count - 1) * 10
            let xPos = startX + CGFloat(columnIndex) * cardSpacingX
            let targetPos = CGPoint(x: xPos, y: yPos)
            
            let delay = Double(columnIndex) * 0.07
            let move = SKAction.move(to: targetPos, duration: 0.25)
            let wait = SKAction.wait(forDuration: delay)
            let group = SKAction.sequence([wait, move, SKAction.run {
                cardNode.removeFromParent()
                self.renderColumns()
            }])
            cardNode.run(group)
        }
    }
    
    func findCardInColumns(byNode node: SKSpriteNode) -> (column: Int, index: Int)? {
        for (colIndex, column) in columns.enumerated() {
            if let idx = column.firstIndex(where: { $0.node == node }) {
                return (colIndex, idx)
            }
        }
        return nil
    }
    
    func isValidDescendingSequence(_ cards: [SpiderCard]) -> Bool {
        guard cards.count > 0 else { return false }
        for i in 0..<(cards.count - 1) {
            let current = cards[i]
            let next = cards[i + 1]
            if current.suit != next.suit || current.rank != next.rank + 1 || !current.isFaceUp || !next.isFaceUp {
                return false
            }
        }
        return true
    }
    
    func findHintMove() -> (fromColumn: Int, fromIndex: Int, toColumn: Int)? {
        for fromColIndex in 0..<columns.count {
            let column = columns[fromColIndex]
            for fromCardIndex in 0..<column.count {
                let movingSequence = Array(column[fromCardIndex...])
                if !isValidDescendingSequence(movingSequence) {
                    continue
                }
                for toColIndex in 0..<columns.count {
                    if toColIndex == fromColIndex { continue }
                    if canPlaceSequence(movingSequence, onColumn: toColIndex) {
                        return (fromColIndex, fromCardIndex, toColIndex)
                    }
                }
            }
        }
        return nil
    }
    
    func highlightHint(fromColumn: Int, fromIndex: Int, toColumn: Int) {
        removeAllHighlights()
        
        let fromCards = columns[fromColumn].suffix(fromIndex)
        for card in fromCards {
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.5) 
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            let repeatPulse = SKAction.repeat(pulse, count: 10)
            
            card.node?.run(repeatPulse, withKey: "highlightPulse")
        }
        
        if let toCard = columns[toColumn].last {
            let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.5)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            let fadePulse = SKAction.sequence([fadeOut, fadeIn])
            let repeatFade = SKAction.repeat(fadePulse, count: 5)
            
            toCard.node?.run(repeatFade, withKey: "highlightFade")
        }
    }

    
    func removeAllHighlights() {
        for column in columns {
            for card in column {
                card.node?.removeAllActions()
                card.node?.alpha = 1.0
                card.node?.setScale(1.0)
            }
        }
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
    
    func findColumnIndex(at point: CGPoint) -> Int? {
        let cardWidth: CGFloat = 45
        let cardSpacingX: CGFloat = cardWidth + 10
        let startX = size.width / 5
        let relativeX = point.x - startX
        if relativeX < 0 { return nil }
        let column = Int(relativeX / cardSpacingX)
        return (column >= 0 && column < columns.count) ? column : nil
    }
    
    func canPlaceSequence(_ sequence: [SpiderCard], onColumn columnIndex: Int) -> Bool {
        let column = columns[columnIndex]
        if column.isEmpty {
            return true
        }
        guard let topCard = column.last else { return false }
        return topCard.rank == sequence.first!.rank + 1
    }
    
    func findColumnOfCard(_ card: SpiderCard) -> Int? {
        for (columnIndex, column) in columns.enumerated() {
            if column.contains(where: { $0.name == card.name && $0.rank == card.rank && $0.suit == card.suit }) {
                return columnIndex
            }
        }
        return nil
    }
    
    func moveSequenceToColumn(_ sequence: [SpiderCard], fromColumn: Int, toColumn: Int) {
        columns[fromColumn].removeLast(sequence.count)
        columns[toColumn].append(contentsOf: sequence)
        if let last = columns[fromColumn].last, !last.isFaceUp {
            columns[fromColumn][columns[fromColumn].count - 1].isFaceUp = true
        }
    }
}
