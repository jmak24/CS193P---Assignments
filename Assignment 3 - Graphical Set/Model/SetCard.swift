//
//  SetCard.swift
//  Set
//
//  Created by Jon Mak on 2018-12-27.
//  Copyright © 2018 Jon Mak. All rights reserved.
//

import Foundation

struct SetCard {
    
    let color: Version
    let shape: Version
    let number: Version
    let fill: Version
    
    enum Version: Int {
        case v1 = 1
        case v2
        case v3
        
        static let all = [v1, v2, v3]
        var index: Int {
            return self.rawValue - 1
        }
    }
    
    static func isSet(_ cards: [SetCard]) -> Bool {
        let sum = [
            cards.reduce(0) { $0 + $1.color.rawValue },
            cards.reduce(0) { $0 + $1.shape.rawValue },
            cards.reduce(0) { $0 + $1.number.rawValue },
            cards.reduce(0) { $0 + $1.fill.rawValue }
        ]
        
        return (sum.reduce(true) { $0 && ($1 % 3 == 0) })
    }
}

enum CardState {
    case normal
    case selected
    case validSet
    case invalidSet
}
