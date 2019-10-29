//
//  SetCard.swift
//  Set
//
//  Created by Jon Mak on 2018-12-27.
//  Copyright © 2018 Jon Mak. All rights reserved.
//

import Foundation

struct SetCard: CustomStringConvertible {
    
    let color: Version
    let shape: Version
    let number: Version
    let fill: Version
    
    var identifier: String {
        return color.rawString + shape.rawString + number.rawString + fill.rawString
    }
    
    var description: String {
        return "color:\(color.rawString), shape:\(shape.rawString), number:\(number.rawString), fill:\(fill.rawString)\n"
    }
    
    enum Version: Int {
        case v1 = 1
        case v2
        case v3
        
        static let all = [v1, v2, v3]
        var index: Int {
            return self.rawValue - 1
        }
        var rawString: String {
            return String(rawValue)
        }
    }
    
    static func isSet(_ cards: [SetCard]) -> Bool {
        let sum = [
            cards.reduce(0) { $0 + $1.color.rawValue },
            cards.reduce(0) { $0 + $1.shape.rawValue },
            cards.reduce(0) { $0 + $1.number.rawValue },
            cards.reduce(0) { $0 + $1.fill.rawValue }
        ]
        for card in cards {
            print("##### SELECTED #####")
            print("Color: ", card.color.rawValue)
            print("Number: ", card.number.rawValue)
            print("Shape: ", card.shape.rawValue)
            print("Fill: ", card.fill.rawValue)
        }

        print("SUM: ", sum)
        let result = (sum.reduce(true) {
            print($0 && ($1 % 3 == 0), " - ", $1)
            return $0 && ($1 % 3 == 0)
        })
        print("RESULT: ", result)
        return (sum.reduce(true) { $0 && ($1 % 3 == 0) })
    }
}

extension SetCard: Hashable {
//    var hashValue: Int {
//        return self.identifier.hashValue
//    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}

func ==(lhs: SetCard, rhs: SetCard) -> Bool {
    return lhs.identifier == rhs.identifier
}

enum CardState {
    case normal
    case selected
    case validSet
    case invalidSet
    case back
}
