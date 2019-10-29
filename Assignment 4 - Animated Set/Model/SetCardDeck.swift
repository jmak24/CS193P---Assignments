//
//  SetCardDeck.swift
//  Set
//
//  Created by Jon Mak on 2018-12-27.
//  Copyright © 2018 Jon Mak. All rights reserved.
//

import Foundation

struct SetCardDeck {
    
    private(set) var cards = [SetCard]()
    
    init() {
        for color in SetCard.Version.all {
            for shape in SetCard.Version.all {
                for number in SetCard.Version.all {
                    for fill in SetCard.Version.all {
                        cards.append(SetCard(color: color, shape: shape, number: number, fill: fill))
                    }
                }
            }
        }
    }
    
    mutating func draw() -> SetCard? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4random)
        } else {
            return nil
        }
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int.random(in: 0..<self)
        } else if self < 0 {
            return -Int.random(in: 0..<abs(self))
        } else {
            return 0
        }
    }
}
