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
    private(set) var numberOfSets: Int = 0
    private(set) var cardsSelected = [SetCard]() {
        didSet {
            if cardsSelected.count == 3 {
                isMatch = SetCard.isSet(cardsSelected)
                if isMatch! { numberOfSets = numberOfSets + 1 }
            } else {
                isMatch = nil
            }
        }
    }
    
    init() { deal(12) }
    
    mutating func choose(this card: SetCard) {
        if cardsSelected.count < 3 {
            // select card
            if !cardsSelected.contains(card) {
                cardsSelected.append(card)
            // deselect card
            } else if let selectedIndex = cardsSelected.index(of: card) {
                cardsSelected.remove(at: selectedIndex)
                score -= 1
            }
        }
        if cardsSelected.count == 3 && isMatch != nil && !cardsSelected.contains(card) {
            // valid Set on field, deselect and replace the 3 cards
            if isMatch! {
                replace3()
            // invalid Set on field, deselect the 3 cards
            } else {
                cardsSelected.removeAll()
            }
            // select card
            cardsSelected.append(card)
        }
    }
    
    mutating func replace3() {
        // replace 3 cards
        if deck.cards.count >= 3 {
            for index in 0..<cards.endIndex {
                if cardsSelected.contains(cards[index]!), let newCard = deck.draw() {
                    cards.remove(at: index)
                    cards.insert(newCard, at: index)
                }
            }
        // deck is empty, remove cards
        } else {
            cards = cards.filter { !cardsSelected.contains($0!) }
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
        numberOfSets = 0
        score = 0
    }
}
