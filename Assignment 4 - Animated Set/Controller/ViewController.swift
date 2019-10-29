//
//  ViewController.swift
//  Concentration
//
//  Created by Jon Mak on 2018-12-19.
//  Copyright © 2018 Jon Mak. All rights reserved.
//

import UIKit

@IBDesignable
class ViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    var flexConstraints = [NSLayoutConstraint]()
    let fieldView = FieldView()
    let dealBackCover = UIButton()
    let dealButton = UIButton()
    let setsBackCover = UIButton()
    let setsButton = UIButton()
    
    var fieldViewBounds: CGRect {
        var bounds = fieldView.bounds
        bounds.size = CGSize(width: fieldView.bounds.width, height: fieldView.bounds.height - menuButtonHeight - 15)
        return bounds
    }
    var menuButtonHeight: CGFloat {
        if UIDevice.current.orientation.isLandscape {
            return self.view.frame.height/6 // Landscape
        } else {
            return self.view.frame.height/10  // Portrait
        }
    }
    var menuButtonWidth: CGFloat {
        return self.menuButtonHeight * 1.59
    }
    
    lazy private var game = SetGame()
    lazy private var grid = Grid(layout: Grid.Layout.aspectRatio(fieldView.cardRatio), frame: fieldViewBounds)
    lazy private var animator = UIDynamicAnimator(referenceView: fieldView)
    lazy private var cardBehavior = CardBehavior(in: animator)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // add Field View Cards
        grid = Grid(layout: Grid.Layout.aspectRatio(fieldView.cardRatio), frame: fieldViewBounds)
        updateViewFromModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.delegate = self
        // Card Field UIView
        self.view.addSubview(fieldView)
        fieldView.translatesAutoresizingMaskIntoConstraints = false
        fieldView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        fieldView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        fieldView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        fieldView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        // add Menu Buttons
        createButton(dealBackCover, name: "DealBackCover", action: nil)
        createButton(dealButton, name: "Deal", action: #selector(deal3Pressed))
        createButton(setsBackCover, name: "SetsBackCover", action: nil)
        createButton(setsButton, name: "Sets: 0", action: #selector(newGamePressed))
        // add gestures
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.deal3More))
        swipe.direction = [.down]
        fieldView.addGestureRecognizer(swipe)
    }

    func createButton(_ button: UIButton, name: String, action: Selector?) {
        fieldView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        if (name == "Deal" || name == "Sets: 0") {
            button.setTitle(name, for: .normal)
            button.setTitleColor(#colorLiteral(red: 0.2293917537, green: 0.1487953663, blue: 0.3850070834, alpha: 1), for: .normal)
            button.titleLabel?.font = UIFont(name: "KohinoorBangla-Semibold", size: 22.0)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 1.0
            button.titleLabel?.numberOfLines = 1
            button.backgroundColor = #colorLiteral(red: 0.9961728454, green: 0.9902502894, blue: 1, alpha: 0)
        }
        if (name == "Deal" || name == "DealBackCover") {
            button.leadingAnchor.constraint(equalTo: fieldView.leadingAnchor, constant: 30.0).isActive = true
        }
        if (name == "Sets: 0" || name == "SetsBackCover") {
            button.trailingAnchor.constraint(equalTo: fieldView.trailingAnchor, constant: -30.0).isActive = true
        }
        if (name == "DealBackCover") { button.backgroundColor = #colorLiteral(red: 0.6968293786, green: 0.6550303102, blue: 0.9880002141, alpha: 1) }
        if (name == "SetsBackCover") { button.backgroundColor = #colorLiteral(red: 0.9961728454, green: 0.9902502894, blue: 1, alpha: 0) }
        if (name == "DealBackCover" || name == "SetsBackCover") {
            button.isEnabled = false
            button.layer.cornerRadius = 12.0
        }
        button.bottomAnchor.constraint(equalTo: fieldView.bottomAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: menuButtonWidth).isActive = true
        flexConstraints.append(button.heightAnchor.constraint(equalToConstant: menuButtonHeight))
        flexConstraints.forEach { $0.isActive = true }
        if action != nil {
            let tap = UITapGestureRecognizer(target: self, action: action)
            button.addGestureRecognizer(tap)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async() {
            for constraint in self.flexConstraints {
                if constraint.firstAttribute == .height { constraint.constant = self.menuButtonHeight }
            }
            self.view.layoutIfNeeded()

            self.grid.frame = self.fieldViewBounds
            self.updateViewFromModel()
        }
    }
    
    @IBAction func newGamePressed(_ sender: UIButton) {
        game.resetGame()
        fieldView.removeAllCards()
        animator = UIDynamicAnimator(referenceView: fieldView)
        animator.delegate = self
        cardBehavior = CardBehavior(in: animator)
        updateViewFromModel()
    }
    
    @IBAction func deal3Pressed(_ sender: UIButton) { deal3More() }
    
    @objc func deal3More() {
        if let matched = game.isMatch, matched && game.deck.cards.count != 0 {
            game.replace3()
        } else if game.deck.cards.count > 0 {
            game.deal(3)
        }
        updateViewFromModel()
    }
    
    @objc func touchCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            if let cardView = sender.view as? SetCardView, let card = cardView.setCard {
                game.choose(this: card)
                updateViewFromModel()
            }
        default: break
        }
    }

    func updateViewFromModel() {
        // update Deal Button Back Cover
        if game.deck.cards.count > 0 {
            dealBackCover.backgroundColor = #colorLiteral(red: 0.6968293786, green: 0.6550303102, blue: 0.9880002141, alpha: 1)
        } else {
            dealBackCover.backgroundColor = #colorLiteral(red: 0.5350045671, green: 0.7172966232, blue: 0.8839030774, alpha: 0)
        }
        // update Sets counter
        setsButton.setTitle("Sets: \(game.numberOfSets)", for: .normal)
        // update Card buttons
        updateCardsFromModel()
    }

    private func updateCardsFromModel() {
        // create updated card views
        var newCardViews = [SetCardView]()
        for index in game.cards.indices {
            grid.cellCount = game.cards.count
            if let card = game.cards[index], let cellRect = grid[index] {
                newCardViews.append(SetCardView(frame: cellRect, at: index, as: card))
            }
        }
        
        // update borders on card views
        let cardViews = fieldView.cardViews
        for cardView in cardViews {
            if let fieldCard = cardView.setCard, game.cardsSelected.contains(fieldCard), game.isMatch != nil {
                let state = game.isMatch! ? CardState.validSet : CardState.invalidSet
                cardView.updateBorder(to: state)
            } else if let fieldCard = cardView.setCard, game.cardsSelected.contains(fieldCard) {
                // update border as selected
                cardView.updateBorder(to: .selected)
            } else {
                cardView.updateBorder(to: .normal)
            }
        }
        
        // animate cards to "flyaway" to discard pile
        let cardsToDiscard = cardViews.getDistinct(from: newCardViews)
        if cardsToDiscard.count > 0 {
            cardsToDiscard.forEach {
                // move cardViews to the end of subview (off the grid)
                fieldView.insertSubview($0, belowSubview: setsButton)
            }
            self.cardBehavior.flyAway(cardsToDiscard, to: self.setsButton.frame)

        }
        // animate cards to be dealt from deck
        let cardsToDeal = newCardViews.getDistinct(from: cardViews)
        if cardsToDeal.count > 0 {
            var delay = 0.0
            for cardToDeal in cardsToDeal {
                let dest = cardToDeal.frame
                cardToDeal.frame = self.dealBackCover.frame
                fieldView(add: cardToDeal)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 1.5,
                        delay: 0,
                        options: [],
                        animations: { cardToDeal.frame = dest },
                        completion: { finished in
                            UIView.transition(
                                with: cardToDeal,
                                duration: 1.0,
                                options: [.transitionFlipFromLeft],
                                animations: { cardToDeal.isFaceUp = true }
                            )
                        }
                    )
                }
                delay = delay + 0.25
            }
        }
        
        rearrangeFieldView(with: newCardViews)
    }
    
    // executes after cards snap to the discard pile
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        let discardPile = animator.items(in: setsButton.frame)
        var cardViews = [SetCardView]()
        discardPile.forEach { cardViews.append($0 as! SetCardView) }
        if discardPile.count > 0 {
            cardViews.sort(by: { $0.index! > $1.index! } )
            for index in 0..<cardViews.endIndex {
                // only flips top card placed in discard pile
                if index == 0 {
                    UIView.transition(
                        with: cardViews[index],
                        duration: 2.5,
                        options: [.transitionFlipFromLeft],
                        animations: { cardViews[index].isFaceUp = false },
                        completion: { finished in
                            cardViews[index].removeFromSuperview()
                            self.setsBackCover.layer.backgroundColor = #colorLiteral(red: 0.6968293786, green: 0.6550303102, blue: 0.9880002141, alpha: 1)
                    })
                } else {
                    cardViews[index].isFaceUp = false
                    cardViews[index].removeFromSuperview()
                }
            }
        }
    }
    
    func rearrangeFieldView(with newCardViews: [SetCardView]) {
        let cardViews = fieldView.cardViews
        // dynamically update the card's insetValue
        for cardView in cardViews {
            // animate card view to its updated frame
            if let newCardView = newCardViews.first(where: { $0 == cardView }) {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.6,
                    delay: 0,
                    options: [],
                    animations: {
                        cardView.index = newCardView.index ?? nil
                        cardView.frame = newCardView.frame
                    },
                    completion: { finished in
                        
                })
            }
        }
    }
    
    func fieldView(add cardToAdd: SetCardView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchCard(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        cardToAdd.addGestureRecognizer(tap)
        fieldView.insertSubview(cardToAdd, at: cardToAdd.index!)
    }
}

extension Array where Element: SetCardView {
    func getDistinct(from otherCardViews: [SetCardView]) -> [SetCardView] {
        return self.filter { !otherCardViews.contains($0) }
    }
}
