import SwiftUI
import SpriteKit

extension CarpetGameSpriteKit {
    func createFourCard() {
        let cardWidth: CGFloat = 45
        let cardHeight: CGFloat = 65
        let startX = size.width / 1.9
        let startY = size.height / 1.26
        let selectedItem = UserDefaultsManager().getSelectedShopItem()
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

    func dealInitialCards() {
        columns = Array(repeating: [], count: 7)
        let selectedItem = UserDefaultsManager().getSelectedShopItem()
        var deckIndex = 0
        for col in 0..<7 {
            for row in 0...col {
                var card = stockCards[deckIndex]
                card.isFaceUp = (row == col) 
                let node = SKSpriteNode(imageNamed: card.isFaceUp ? textureName(for: card) : selectedItem?.backName ?? "spiderBackCard")
                node.size = CGSize(width: 45, height: 65)
                node.position = CGPoint(x: size.width / 8 + CGFloat(col) * 50, y: size.height / 2 - CGFloat(row) * 25)
                node.name = "card"
                addChild(node)
                card.node = node
                columns[col].append(card)
                deckIndex += 1
            }
        }
        stockCards = Array(stockCards[deckIndex...])
    }

    func dealCardFromStock() {
        guard !stockCards.isEmpty else { return }
        var card = stockCards.removeLast()
        card.isFaceUp = true
        let node = SKSpriteNode(imageNamed: textureName(for: card))
        node.size = CGSize(width: 45, height: 65)
        node.position = CGPoint(x: size.width / 2, y: size.height / 8)
        node.name = "wasteCard"
        addChild(node)
        card.node = node
        wasteCards.append(card)
        currentNewCard = card
    }

    func createFourCard2() {
        let cardWidth: CGFloat = 45
        let cardHeight: CGFloat = 65
        let startX = size.width / 4.3
        let startY = size.height / 1.26
        let selectedItem = UserDefaultsManager().getSelectedShopItem()
        for column in 0..<4 {
            let cardNode = SKSpriteNode(imageNamed: selectedItem?.backName ?? "spiderBackCard")
            cardNode.name = "foundationSlot2"
            cardNode.size = CGSize(width: cardWidth, height: cardHeight)
            let xPos = startX + CGFloat(column) * 55
            let yPos = startY
            cardNode.position = CGPoint(x: xPos, y: yPos)
            addChild(cardNode)
            foundationNodes.append(cardNode)
            freeCellNodes.append(cardNode)
        }
    }
    
    func renderFoundations() {
        for (foundationIdx, pile) in foundationPiles.enumerated() {
            if let card = pile.last, let node = card.node {
                let foundationNode = foundationNodes[foundationIdx]
                node.position = foundationNode.position
                node.zPosition = 100
                node.texture = SKTexture(imageNamed: textureName(for: card))
                addChild(node)
            }
        }
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
    
    func createCards() {
        createDeck()
        columns = Array(repeating: [], count: 8)
        let stackCounts = [7,7,7,7,6,6,6,6]
        for column in 0..<8 {
            for _ in 0..<stackCounts[column] {
                if let cardName = getNextCard() {
                    let (suit, rank) = parseCardName(cardName)
                    let card = CarpetCard(name: cardName, suit: suit, rank: rank, isFaceUp: true, node: nil)
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
        let cardWidth: CGFloat = 45
        let cardHeight: CGFloat = 65
        let startX = size.width / 4
        let startY = size.height / 1.8
        let cardSpacingY: CGFloat = 10
        let cardSpacingX: CGFloat = cardWidth + 10
        let selectedItem = UserDefaultsManager().getSelectedShopItem()
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
