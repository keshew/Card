import SwiftUI
import SpriteKit

extension AgnesGameSpriteKit {

    
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
                let card = SolitaireCard(name: "\(rank)_\(suit)", suit: suit, rank: rank, isFaceUp: false, node: nil)
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
