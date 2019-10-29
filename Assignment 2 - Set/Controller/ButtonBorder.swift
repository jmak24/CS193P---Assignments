//
//  ButtonBorder.swift
//  Set
//
//  Created by Jon Mak on 2018-12-26.
//  Copyright © 2018 Jon Mak. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable class ButtonBorder: UIButton {
    
    @IBInspectable var buttonColor: UIColor = UIColor.clear
    @IBInspectable var buttonBorderWidth: CGFloat = 4.0
    @IBInspectable var buttonBorderRadius: CGFloat = 12.0
    @IBInspectable var buttonBorderColor: UIColor = #colorLiteral(red: 0.8806701591, green: 0.8893896656, blue: 0.8893896656, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        styleView()
    }
    
    override func prepareForInterfaceBuilder() {
        styleView()
    }
    
    func styleView() {
        backgroundColor = buttonColor
        layer.borderWidth = buttonBorderWidth
        layer.borderColor = buttonBorderColor.cgColor
        layer.cornerRadius = buttonBorderRadius
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        self.titleLabel?.font = UIFont.systemFont(ofSize: 28)
    }
}
