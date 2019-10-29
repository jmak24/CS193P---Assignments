//
//  ConcentrationThemeChooserViewController.swift
//  Concentration
//
//  Created by Jon Mak on 2019-01-11.
//  Copyright © 2019 Jon Mak. All rights reserved.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController, UISplitViewControllerDelegate {

    private let themes = [
        "Animals":"🐶🐱🦊🐻🐷🐨🐯🐮🐵🐸",
        "Fruits":"🥭🍎🍐🍊🍌🍉🍇🍓🍑🍍",
        "Junk Food":"🍔🍟🍕🍜🌮🍫🍣🍰🌯🍗",
        "Sports":"🏀⚽️🏈⚾️🥎🏐🏉🏒🏓🏸",
        "Vehicles":"🚙🚕🚎🏎🚓🚑🚒🚛🚜🛵",
        "Technology":"💻📱🖥🖨🖱⌚️⌨️💿📷🎛"
    ]
    
    override func awakeFromNib() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 20)!], for: .normal)
        
        splitViewController?.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let cvc = secondaryViewController as? ConcentrationViewController {
            // if theme is set, return true to not collapse (display Master View)
            if cvc.theme == nil {
                return true
            }
        }
        // else collapse for me (display Detail View)
        return false
    }
    
    @IBAction func changeTheme(_ sender: Any) {
        // iPad Devices (split view) - directly updates the theme (of Concentration view controlller) on the fly without performing a segue that will create a new MVC or instance of the game
        if let cvc = splitViewConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
            }
        // iPhone Devices (no split view) - grabs the last saved Concentration view controller segued to and pushes that to the navigation controller
        } else if let cvc = lastSeguedToConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
            }
            navigationController?.pushViewController(cvc, animated: true)
        } else {
            performSegue(withIdentifier: "Choose Theme", sender: sender)
        }
    }
    
    var splitViewConcentrationViewController: ConcentrationViewController? {
        return splitViewController?.viewControllers.last as? ConcentrationViewController
    }
    
    private var lastSeguedToConcentrationViewController: ConcentrationViewController?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Choose Theme" {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                if let cvc = segue.destination as? ConcentrationViewController {
                    cvc.theme = theme
                    lastSeguedToConcentrationViewController = cvc
                }
            }
        }
    }
}
