//
//  ViewController.swift
//  Concentration
//
//  Created by Jon Mak on 2018-12-19.
//  Copyright © 2018 Jon Mak. All rights reserved.
//

import UIKit

@IBDesignable
class ViewController: UIViewController {
    
    var flexConstraints = [NSLayoutConstraint]()
    let fieldView = FieldView()
    let deal3Button = UIButton()
    let newGameButton = UIButton()
    let scoreLabel = UILabel()
    let cardsLabel = UILabel()
    var menuStackHeight: CGFloat {
        if UIDevice.current.orientation.isLandscape {
            return self.view.frame.height/8 // Landscape
        } else {
            return self.view.frame.height/10  // Portrait
        }
    }
    var menuStack = UIStackView()
    
    lazy private var game = SetGame()
    lazy private var grid = Grid(layout: Grid.Layout.aspectRatio(fieldView.cardRatio), frame: fieldView.bounds)
    
    override func viewDidAppear(_ animated: Bool) {
        grid = Grid(layout: Grid.Layout.aspectRatio(fieldView.cardRatio), frame: fieldView.bounds)
        print(fieldView.bounds)
        updateViewFromModel()
    }
    
    
    override func viewDidLoad() {
        super.loadView()

        // Create Menu StackView
        var counterViews = [UIStackView]()
        counterViews.append(createLabelStack(scoreLabel, labelText: "Score"))
        counterViews.append(createLabelStack(cardsLabel, labelText: "Cards"))

        let menuViews: [UIView] = [
            createButton(newGameButton, labelText: "New Game", position: "left", action: #selector(newGamePressed)),
            createStackView(of: counterViews, NSLayoutConstraint.Axis.horizontal, 5.0),
            createButton(deal3Button, labelText: "Deal 3 More", position: "right", action: #selector(deal3Pressed))
        ]
        menuStack = createStackView(of: menuViews, NSLayoutConstraint.Axis.horizontal, 0.0)
        self.view.addSubview(menuStack)
        menuStack.translatesAutoresizingMaskIntoConstraints = false
        menuStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        menuStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        menuStack.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        flexConstraints.append(menuStack.heightAnchor.constraint(equalToConstant: menuStackHeight))
        flexConstraints.forEach { $0.isActive = true }
        menuStack.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        // Card Field UIView
        self.view.addSubview(fieldView)
        fieldView.translatesAutoresizingMaskIntoConstraints = false
        fieldView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        fieldView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        fieldView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        fieldView.bottomAnchor.constraint(equalTo: menuStack.topAnchor, constant: -15.0).isActive = true
        // add gestures
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.deal3More))
        swipe.direction = [.down]
        fieldView.addGestureRecognizer(swipe)
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(self.shuffleCardsInView))
        rotate.rotation = 0
        fieldView.addGestureRecognizer(rotate)
    }

    func createButton(_ button: UIButton, labelText: String, position: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0.2316657305, green: 0.4662804604, blue: 0.7434015274, alpha: 1)
        button.setTitle(labelText, for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 20.0)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 1.0
        button.titleLabel?.numberOfLines = 2
        button.contentEdgeInsets = UIEdgeInsets(top: 5,left: 15,bottom: 5,right: 15)

        let tap = UITapGestureRecognizer(target: self, action: action)
        button.addGestureRecognizer(tap)
        return button
    }
    
    func createLabelStack(_ counterLabel: UILabel, labelText: String) -> UIStackView {
        // Text Label
        let label = UILabel()
        label.text = labelText
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 1.0
        label.textColor = #colorLiteral(red: 0.6147909164, green: 0.6198039651, blue: 0.6196082234, alpha: 1)
        // Counter Label
        counterLabel.textAlignment = .center
        counterLabel.font = UIFont(name: "HelveticaNeue-Light", size: 28.0)
        counterLabel.adjustsFontSizeToFitWidth = true
        counterLabel.numberOfLines = 1
        counterLabel.textColor = #colorLiteral(red: 0.3281167389, green: 0.5502234988, blue: 1, alpha: 1)
        // return StackView
        let views = [label, counterLabel]
        return createStackView(of: views, NSLayoutConstraint.Axis.vertical, 3.0)
    }
    
    func createStackView(of views: [UIView], _ axis: NSLayoutConstraint.Axis, _ spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        views.forEach { stackView.addArrangedSubview($0) }
        stackView.axis = axis
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing = spacing
        return stackView
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async() {
            for constraint in self.flexConstraints {
                if constraint.firstAttribute == .height { constraint.constant = self.menuStackHeight }
            }
            
            self.view.layoutIfNeeded()

            self.grid.frame = self.fieldView.bounds
            self.updateViewFromModel()
        }
    }
    
    @IBAction func newGamePressed(_ sender: UIButton) {
        game.resetGame()
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
    
    @objc func shuffleCardsInView(_ sender: UIRotationGestureRecognizer) {
        // trigger when rotated 1/6 of a circle
        if sender.rotation > CGFloat.pi/3 {
            sender.rotation = 0
            game.rearrangeCards()
            updateViewFromModel()
        }
    }
    
    @objc func touchCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            if let cardView = sender.view as? SetCardView, let cardNumber = cardView.index {
                if game.cards.indices.contains(cardNumber) {
                    game.chooseCard(at: cardNumber)
                    updateViewFromModel()
                }
            }
        default: break
        }
    }

    func updateViewFromModel() {
        // update Deal 3 More Cards button
        if let matched = game.isMatch, matched && game.deck.cards.count != 0 {
            deal3Button.backgroundColor = #colorLiteral(red: 0.2030524929, green: 0.4801130338, blue: 0.7937222398, alpha: 1)
        } else if game.deck.cards.count > 0 {
            deal3Button.backgroundColor = #colorLiteral(red: 0.2030524929, green: 0.4801130338, blue: 0.7937222398, alpha: 1)
        } else {
            deal3Button.backgroundColor = #colorLiteral(red: 0.5350045671, green: 0.7172966232, blue: 0.8839030774, alpha: 1)
        }
        // update Card buttons
        updateCardsFromModel()
        // update Score Counter Label
        scoreLabel.text = String(game.score)
        // update Card Counter Label
        cardsLabel.text = String(game.cards.count + game.deck.cards.count)
    }

    private func updateCardsFromModel() {
        var cardViews = [SetCardView]()
        
        for index in game.cards.indices {
            var state: CardState = .normal
            grid.cellCount = game.cards.count

            if let card = game.cards[index], let cellRect = grid[index] {
                if game.cardsSelected.contains(index), game.isMatch != nil {
                    state = game.isMatch! ? CardState.validSet : CardState.invalidSet
                } else if game.cardsSelected.contains(index) {
                    state = CardState.selected
                }
                
                cardViews.append(SetCardView(frame: cellRect, at: index, as: card, is: state))
            }
        }
        
        fieldView.cardViews = cardViews
        updateFieldView()
    }
    
    func updateFieldView() {
        // dynamically set insetValue
        fieldView.insetValue = fieldView.cardViews.indices.contains(0) ? fieldView.cardViews[0].frame.width/30 : 1.0
        // remove all existing subviews
        fieldView.subviews.forEach { $0.removeFromSuperview() }
        // add new set of subviews
        for cardView in fieldView.cardViews {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchCard(_:)))
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            cardView.addGestureRecognizer(tap)
            cardView.bounds = cardView.bounds.insetBy(dx: fieldView.insetValue, dy: fieldView.insetValue)
            fieldView.addSubview(cardView)
        }
    }
}
