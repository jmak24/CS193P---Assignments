//
//  FieldView.swift
//  Graphical Set
//
//  Created by Jon Mak on 2019-01-04.
//  Copyright © 2019 Jon Mak. All rights reserved.
//

import UIKit

@IBDesignable
class FieldView: UIView {

    var cardViews: [SetCardView] {
        return self.subviews.filter{
            if let cardView = $0 as? SetCardView, cardView.setCard != nil {
                return true
            } else {
                return false
            }
        }.map{$0 as! SetCardView }
    }
    var insetValue: CGFloat = 1.0 // spacing between each card
    let cardRatio: CGFloat = 1.59 // width to height ratio of card
    
    func removeAllCards() {
        self.subviews.forEach{
            if let cardView = ($0 as? SetCardView) { cardView.removeFromSuperview() }
        }
    }

}


