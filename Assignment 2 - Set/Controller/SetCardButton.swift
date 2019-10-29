//
//  SetCardButton.swift
//  Assignment 2
//
//  Created by Jon Mak on 2018-05-23.
//  Copyright © 2018 Jon Mak. All rights reserved.
//

import UIKit

@IBDesignable class SetCardButton: ButtonBorder {
    
    let colors = [#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)]
    let alphas: [CGFloat] = [1.0, 0.40, 0.15]
    let strokeWidths: [CGFloat] = [ -8, 8, -8]
    let symbols = ["●", "▲", "■"]
    
    var setCard: SetCard?
    
    func createAttributes() -> NSAttributedString {
        let card = setCard!
        var attributes: [NSAttributedString.Key: Any] = [:]
        let color = colors[card.color.index]
        attributes[.strokeColor] = color
        attributes[.foregroundColor] = color.withAlphaComponent(alphas[card.shade.index])
        attributes[.strokeWidth] = strokeWidths[card.shade.index]
        var symbol = symbols[card.shape.index]
        if card.number.rawValue == 2 {
            symbol += " " + symbol
        } else if card.number.rawValue == 3 {
            symbol += " " + symbol + " " + symbol
        }
        return NSAttributedString(string: symbol, attributes: attributes)
    }
    
    func updateCard() {
        if setCard != nil {
            setTitle(nil, for: .normal)
            layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
            layer.borderWidth = 4.0
            let attributedString = createAttributes()
            setAttributedTitle(attributedString, for: .normal)
        } else {
            layer.borderWidth = 0
            setAttributedTitle(nil, for: .normal)
        }
    }
    
    func updateBorder (to state: CardState) {
        switch state {
        case .normal:
            layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        case .selected:
            layer.borderColor = #colorLiteral(red: 0.2941703259, green: 0.5948605214, blue: 0.8275499683, alpha: 1)
        case .validSet:
            layer.borderColor = #colorLiteral(red: 0.5262068795, green: 0.8180123731, blue: 0.3264481139, alpha: 1)
        case .invalidSet:
            layer.borderColor = #colorLiteral(red: 1, green: 0.3246987098, blue: 0.3140562176, alpha: 1)
        }
    }
    
}
