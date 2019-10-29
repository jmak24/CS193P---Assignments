//
//  File.swift
//  Animated Set
//
//  Created by Jon Mak on 2019-01-15.
//  Copyright © 2019 Jon Mak. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.resistance = 0.3
        behavior.allowsRotation = true
        behavior.elasticity = 0.7
        return behavior
    }()
    
    private func pushBehavior(add item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = CGFloat.pi + CGFloat.random(in: 0...CGFloat.pi)
        push.magnitude = CGFloat(3.0) + CGFloat.random(in: 2...5.0)
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    private func snapBehavior(add item: UIDynamicItem, snapTo dest: CGRect) {
        let snap = UISnapBehavior(item: item, snapTo:
            CGPoint(x: dest.origin.x + (dest.size.width/2),
                    y: dest.origin.y + (dest.size.height/2)))
        snap.damping = 1.0
        snap.action = { [unowned snap, weak self] in
            if let cardView = item as? SetCardView {
//                if floor(cardView.frame.origin.x) == floor(dest.origin.x),
//                    floor(cardView.frame.origin.y) == floor(dest.origin.y) {
//                self?.removeChildBehavior(snap)
//                }
                if !cardView.isFaceUp { self?.removeChildBehavior(snap) }
            }
        }
        addChildBehavior(snap)
    }
    
    func flyAway(_ items: [UIDynamicItem], to dest: CGRect) {
        var delay = 1.0
        for item in items {
            let cardView = item as! SetCardView
        
            itemBehavior.addItem(item)
            collisionBehavior.addItem(item)
            cardView.reduceDropShadow()
            cardView.setCard = nil
            pushBehavior(add: item)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.collisionBehavior.removeItem(item)
                self.itemBehavior.removeItem(item)
                self.snapBehavior(add: item, snapTo: dest)
            }
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.4,
                delay: delay,
                options: [],
                animations: { cardView.frame.size = CGSize(width: dest.size.width, height: dest.size.height)
            })
            delay = delay + 0.1
        }
    }
        
    func addItems(_ item: UIDynamicItem) {
        itemBehavior.addItem(item)
        collisionBehavior.addItem(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        itemBehavior.removeItem(item)
        collisionBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(itemBehavior)
        addChildBehavior(collisionBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
