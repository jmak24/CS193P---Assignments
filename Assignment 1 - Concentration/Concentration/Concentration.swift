//
//  Concentration.swift
//  Concentration
//
//  Created by Jon Mak on 2018-12-21.
//  Copyright © 2018 Jon Mak. All rights reserved.
//

import Foundation

struct Concentration {
    
    private(set) var cards = [Card]()
    
    private(set) var flipCount = 0
    private(set) var score = 0
    
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            return cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    init(numberOfPairsOfCards: Int) {
        for _ in 0..<(numberOfPairsOfCards) {
            let card = Card()
            cards += [card, card]
        }
        
        cards.shuffle()
    }
    
    mutating func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): chosen index not in cards")
        if !cards[index].isMatched && cards[index].isFaceUp == false {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                if cards[matchIndex] == cards[index] {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    score += 2
                } else {
                    if score >= 1 {
                        if cards[index].cardSeen { score -= 1 }
                        if cards[matchIndex].cardSeen { score -= 1}
                    }
                }
                cards[index].isFaceUp = true
            } else {
                indexOfOneAndOnlyFaceUpCard = index
            }
            cards[index].cardSeen = true
            flipCount += 1
        }
    }
    
    mutating func reset() {
        let numberOfPairsOfCards = cards.count/2
        cards.removeAll()
        
        for _ in 0..<(numberOfPairsOfCards) {
            let card = Card()
            cards += [card, card]
        }
        
        cards.shuffle()
        indexOfOneAndOnlyFaceUpCard = nil
        flipCount = 0
        score = 0
    }
}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? self.first : nil
    }
}
