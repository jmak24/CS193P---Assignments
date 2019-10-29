//
//  Set.swift
//  Set
//
//  Created by Jon Mak on 2018-12-21.
//  Copyright © 2018 Jon Mak. All rights reserved.
//

import Foundation

struct SetGame {
    
    private(set) var deck = SetCardDeck()
    private(set) var cards = [SetCard?]()
    private(set) var score = 0
    private(set) var isMatch: Bool?
    private(set) var cardsSelected = [Int]() {
        didSet {
            if cardsSelected.count == 3 {
                var checkCards = [SetCard]()
                for index in cardsSelected {
                    assert(cards.indices.contains(index), "Index: \(index) not found in cards")
                    if cards.indices.contains(index), let card = cards[index] {
                        checkCards.append(card)
                    }
                }
                isMatch = SetCard.isSet(checkCards)
                score += isMatch! ? 3 : -5
            } else {
                isMatch = nil
            }
        }
    }
    
    init() { deal(12) }
    
    mutating func chooseCard(at index: Int) {
        if cardsSelected.count < 3 {
            // select card
            if !cardsSelected.contains(index) {
                cardsSelected.append(index)
            // deselect card
            } else if let selectedIndex = cardsSelected.index(of: index) {
                cardsSelected.remove(at: selectedIndex)
                score -= 1
            }
        }
        if cardsSelected.count == 3 && isMatch != nil && !cardsSelected.contains(index) {
            // valid Set on field, deselect and replace the 3 cards
            if isMatch! {
                replace3()
            // invalid Set on field, deselect the 3 cards
            } else {
                cardsSelected.removeAll()
            }
            // select card
            cardsSelected.append(index)
        }
    }
    
    mutating func replace3() {
        for index in cardsSelected {
            if cards.indices.contains(index) {
                cards.remove(at: index)
                cards.insert(deck.draw(), at: index)
            }
        }
        cardsSelected.removeAll()
    }
    
    mutating func deal(_ amount: Int) {
        for _ in 1...amount {
            if let newCard = deck.draw() {
                cards.append(newCard)
            } else {
                print("No cards remaining")
                return
            }
        }
    }
    
    mutating func resetGame() {
        cards.removeAll()
        cardsSelected.removeAll()
        deck = SetCardDeck()
        deal(12)
        isMatch = nil
        score = 0
    }
}
