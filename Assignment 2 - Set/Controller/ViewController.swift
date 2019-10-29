//
//  ViewController.swift
//  Concentration
//
//  Created by Jon Mak on 2018-12-19.
//  Copyright © 2018 Jon Mak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var game = SetGame()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
    }
    
    @IBOutlet var cardButtons: [SetCardButton]!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var cardsLabel: UILabel!
    @IBOutlet weak var deal3Button: UIButton!

    @IBAction func newGamePressed(_ sender: UIButton) {
        game.resetGame()
        updateViewFromModel()
    }
    
    @IBAction func deal3Pressed(_ sender: UIButton) {
        if let matched = game.isMatch, matched && game.deck.cards.count != 0 {
            game.replace3()
        } else if game.cards.count < cardButtons.count {
            game.deal(3)
        }
        updateViewFromModel()
    }
    
    @IBAction func touchCard(_ sender: SetCardButton) {
        if let cardNumber = cardButtons.index(of: sender), game.cards.indices.contains(cardNumber) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        }
    }
    
    func updateViewFromModel() {
        // update Deal 3 More Cards button
        if let matched = game.isMatch, matched && game.deck.cards.count != 0 {
            deal3Button.backgroundColor = #colorLiteral(red: 0.2030524929, green: 0.4801130338, blue: 0.7937222398, alpha: 1)
        } else if game.cards.count < cardButtons.count {
            deal3Button.backgroundColor = #colorLiteral(red: 0.2030524929, green: 0.4801130338, blue: 0.7937222398, alpha: 1)
        } else {
            deal3Button.backgroundColor = #colorLiteral(red: 0.5350045671, green: 0.7172966232, blue: 0.8839030774, alpha: 1)
        }
        // update Card buttons
        updateButtonsFromModel()
        // update Cards Label
        cardsLabel.text = String(game.deck.cards.count)
        // update Score Label
        scoreLabel.text = String(game.score)
    }
    
    private func updateButtonsFromModel() {
        for index in cardButtons.indices {
            var state: CardState = .normal
            let button = cardButtons[index]
            if game.cards.indices.contains(index), let card = game.cards[index] {
                button.setCard = card
                if game.cardsSelected.contains(index), game.isMatch != nil {
                    state = game.isMatch! ? CardState.validSet : CardState.invalidSet
                } else if game.cardsSelected.contains(index) {
                    state = CardState.selected
                }
            } else {
                button.setCard = nil
            }
            button.updateCard()
            button.updateBorder(to: state)
        }
    }
}
