//
//  SetCardButton.swift
//  Assignment 2
//
//  Created by Jon Mak on 2018-05-23.
//  Copyright © 2018 Jon Mak. All rights reserved.
//

import UIKit

@IBDesignable class SetCardView: UIView {
    
    var setCard: SetCard?
    var index: Int?
    var isFaceUp: Bool = false {
        didSet {
            self.cardState = isFaceUp ? .normal : .back
            setNeedsDisplay()
        }
    }
    private var cardState: CardState?
    
    @IBInspectable private let cardColor: UIColor = UIColor.clear
    @IBInspectable private let cardBorderWidth: CGFloat = 3.0
    @IBInspectable private let cardBorderRadius: CGFloat = 12.0
    @IBInspectable private let shapeLineWidth: CGFloat = 4.0
    
    private var fill: Fill?
    private var shape: Shape?
    private var color: UIColor?
    private var number: Int?
    
    private enum Fill: Int {
        case empty = 1
        case solid
        case stripes
    }
    
    private enum Shape: Int {
        case oval = 1
        case diamond
        case squiggle
    }
    
    private struct Colors {
        static let red: UIColor = #colorLiteral(red: 0.8392156863, green: 0.3411764706, blue: 0, alpha: 1)
        static let green: UIColor = #colorLiteral(red: 0.3333333333, green: 0.6705882353, blue: 0.4, alpha: 1)
        static let purple: UIColor = #colorLiteral(red: 0.5137254902, green: 0.2941176471, blue: 0.6588235294, alpha: 1)
        
        static let all = [Colors.red, Colors.green, Colors.purple]
        static func getColor(_ index: Int) -> UIColor {
            return all[index]
        }
    }
    
    init(frame: CGRect, at index: Int, as setCard: SetCard) {
        super.init(frame: frame)
        self.setCard = setCard
        self.index = index
        self.cardState = .normal
        self.isOpaque = false
        
        if let fillEnum = Fill(rawValue: setCard.fill.rawValue) { self.fill = fillEnum }
        if let shapeEnum = Shape(rawValue: setCard.shape.rawValue) { self.shape = shapeEnum }
        self.color = Colors.getColor(setCard.color.index)
        self.number = setCard.number.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var hash: Int {
        return setCard!.identifier.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let otherCardView = object as? SetCardView {
            if self.setCard != nil && otherCardView.setCard != nil {
                return self.setCard! == otherCardView.setCard!
            }
        }
        return false
    }
    
    private func pathForOval(offsetByX: CGFloat) -> UIBezierPath {
        let ovalPath = UIBezierPath()
        ovalPath.move(to: CGPoint(x: bounds.midX - symbolWidth/2 + offsetByX, y: bounds.midY + symbolHeight/2 - symbolWidth/2))
        ovalPath.addLine(to: CGPoint(x: bounds.midX - symbolWidth/2 + offsetByX, y: bounds.midY - symbolHeight/2 + symbolWidth/2))
        ovalPath.addArc(withCenter: CGPoint(x: bounds.midX + offsetByX, y: bounds.midY - symbolHeight/2 + symbolWidth/2),
                        radius: symbolWidth/2, startAngle: CGFloat(Double.pi), endAngle: 0.0, clockwise: true)
        ovalPath.addLine(to: CGPoint(x: bounds.midX + symbolWidth/2 + offsetByX, y: bounds.midY + symbolHeight/2 - symbolWidth/2))
        ovalPath.addArc(withCenter: CGPoint(x: bounds.midX + offsetByX, y: bounds.midY + symbolHeight/2 - symbolWidth/2),
                        radius: symbolWidth/2, startAngle: CGFloat(0.0), endAngle: CGFloat(Double.pi), clockwise: true)
        
        return ovalPath
    }
    
    private func pathForDiamond(offsetByX: CGFloat) -> UIBezierPath {
        let diamondPath = UIBezierPath()
        diamondPath.move(to: CGPoint(x: bounds.midX - symbolWidth/2 + offsetByX, y: bounds.midY))
        diamondPath.addLine(to: CGPoint(x: bounds.midX + offsetByX, y: bounds.midY - symbolHeight/2))
        diamondPath.addLine(to: CGPoint(x: bounds.midX + symbolWidth/2 + offsetByX, y: bounds.midY))
        diamondPath.addLine(to: CGPoint(x: bounds.midX + offsetByX, y: bounds.midY + symbolHeight/2))
        diamondPath.addLine(to: CGPoint(x: bounds.midX - symbolWidth/2 + offsetByX, y: bounds.midY))
        
        return diamondPath
    }
    
    private func pathForSquiggle(offsetByX: CGFloat) -> UIBezierPath {
        let squigglePath = UIBezierPath()
        squigglePath.move(to: CGPoint(x: bounds.midX + offsetByX, y: bounds.midY - (symbolHeight/2 * 0.9)))
        squigglePath.addCurve(to: CGPoint(x: bounds.midX + symbolWidth/2 + offsetByX, y: (bounds.midY + symbolHeight/2) * 0.85),
                              controlPoint1: CGPoint(x: bounds.midX + (symbolWidth/2 * 2.3) + offsetByX, y: bounds.midY - (symbolHeight/2 * 0.2)),
                              controlPoint2: CGPoint(x: bounds.midX - (symbolWidth/2 * 0.15) + offsetByX, y: bounds.midY + (symbolHeight/2) * 0.1))
        squigglePath.addQuadCurve(to: CGPoint(x: bounds.midX + offsetByX, y: bounds.midY + (symbolHeight/2) * 1),
                                  controlPoint: CGPoint(x: bounds.midX + (symbolWidth/2 * 1.3) + offsetByX, y: bounds.midY + (symbolHeight/2) * 1.2))
        squigglePath.addCurve(to: CGPoint(x: bounds.midX - (symbolWidth/2 * 0.9) + offsetByX, y: bounds.midY - (symbolHeight/2) * 0.68),
                              controlPoint1: CGPoint(x: bounds.midX - (symbolWidth/2 * 1.9) + offsetByX, y: bounds.midY + (symbolHeight/2 * 0.6)),
                              controlPoint2: CGPoint(x: bounds.midX + (symbolWidth/2 * 0.3) + offsetByX, y: bounds.midY ))
        squigglePath.addQuadCurve(to: CGPoint(x: bounds.midX + offsetByX, y: bounds.midY - (symbolHeight/2 * 0.9)),
                                  controlPoint: CGPoint(x: bounds.midX - (symbolWidth/2 * 1.1) + offsetByX, y: bounds.midY - (symbolHeight/2) * 1.1))
        return squigglePath
    }
    
    private func drawStripes() {
        let T: CGFloat = 1 // thickness of lines
        let G: CGFloat = 3.0 // gap between lines
        let W = bounds.maxX
        let H = bounds.maxY
        
        let stripePath = UIBezierPath()
        stripePath.lineWidth = 0.5
        
        var p = CGFloat(0.0)
        while p <= H {
            stripePath.move(to: CGPoint(x: 0.0, y: p+T))
            stripePath.addLine(to: CGPoint(x: p+W, y: p+T))
            stripePath.stroke()
            p += G + T
        }
    }
    
    private func addStripes(_ path: UIBezierPath) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        path.addClip()
        drawStripes()
        context?.restoreGState()
    }
    
    private func getSymbolPaths(of number: Int, with pathFunc: (CGFloat) -> UIBezierPath) -> [UIBezierPath] {
        var paths = [UIBezierPath]()
        if number == 3 {
            paths.append(pathFunc(-bounds.maxX/3))
            paths.append(pathFunc(0))
            paths.append(pathFunc(bounds.maxX/3))
        } else if number == 2 {
            paths.append(pathFunc(-bounds.maxX/5))
            paths.append(pathFunc(bounds.maxX/5))
        } else if number == 1 {
            paths.append(pathFunc(0))
        }
        
        return paths
    }
    
    private func drawPaths(_ paths: [UIBezierPath], with fill: Fill) {
        assert (paths.count != 0, "card does not contain any UIBezier paths")
        guard let color = self.color else { return }

        for path in paths {
            path.lineWidth = shapeLineWidth
            switch fill {
            case .empty:
                UIColor.clear.setFill()
                color.setStroke()
                path.stroke()
            case .solid:
                color.setStroke()
                color.setFill()
                path.fill()
            case .stripes:
                UIColor.clear.setFill()
                color.setStroke()
                path.stroke()
                addStripes(path)
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        if isFaceUp {
            self.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            guard let shape = self.shape else { return }
            guard let fill = self.fill else { return }
            guard let number = self.number else { return }
            // get shape paths
            let pathFunc: (CGFloat) -> UIBezierPath
            switch shape {
            case .oval:
                pathFunc = pathForOval
            case .diamond:
                pathFunc = pathForDiamond
            case .squiggle:
                pathFunc = pathForSquiggle
            }
            // draw the shape with fill and color
            let paths = getSymbolPaths(of: number, with: pathFunc)
            drawPaths(paths, with: fill)
            
            // update border (based on card state)
            updateBorder(to: cardState!)
            dropShadow()
        } else {
            updateBorder(to: .back)
        }
    }
    
    func updateBorder(to state: CardState) {
        layer.cornerRadius = cardBorderRadius
        
        switch state {
        case .normal:
            layer.borderWidth = 0.0
            layer.borderColor = #colorLiteral(red: 0.8515723348, green: 0.8465108871, blue: 0.855463624, alpha: 1)
        case .selected:
            layer.borderWidth = cardBorderWidth
            layer.borderColor = #colorLiteral(red: 0.2941703259, green: 0.5948605214, blue: 0.8275499683, alpha: 1)
        case .validSet:
            layer.borderWidth = cardBorderWidth
            layer.borderColor = #colorLiteral(red: 0.5262068795, green: 0.8180123731, blue: 0.3264481139, alpha: 1)
        case .invalidSet:
            layer.borderWidth = cardBorderWidth
            layer.borderColor = #colorLiteral(red: 1, green: 0.3246987098, blue: 0.3140562176, alpha: 1)
        case .back:
            layer.borderWidth = 0.0
            layer.backgroundColor = #colorLiteral(red: 0.6968293786, green: 0.6550303102, blue: 0.9880002141, alpha: 1)
        }
    }
    
    private func dropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = #colorLiteral(red: 0.280924648, green: 0.305198729, blue: 0.3377195001, alpha: 1)
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 1, height: -1)
        layer.shadowRadius = 12.0

//        layer.shouldRasterize = true
//        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func reduceDropShadow() {
        layer.shadowOpacity = 0.05
        //layer.shouldRasterize = false
    }
}

extension SetCardView {
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let symbolSizeToBoundsSize: CGFloat = 0.3
        static let symbolToBoundsWidth: CGFloat = 0.2
        static let symbolToBoundsHeight: CGFloat = 0.8
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var symbolWidth: CGFloat {
        return bounds.size.width * SizeRatio.symbolToBoundsWidth
    }
    private var symbolHeight: CGFloat {
        return bounds.size.height * SizeRatio.symbolToBoundsHeight
    }

}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
