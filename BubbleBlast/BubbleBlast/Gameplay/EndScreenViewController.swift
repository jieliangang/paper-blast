//
//  EndScreenViewController.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 3/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import UIKit

class EndScreenViewController: UIViewController {

    @IBOutlet var endScreenText: UILabel!

    var result: (Bool, PlayerType) = (false, .single)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 5.0
        
        switch result {
        case (true, .single):
            endScreenText.text = "You win!"
        case (true, .one), (false, .two):
            endScreenText.text = "Player One win!"
        case (true, .two), (false, .one):
            endScreenText.text = "Player Two win!"
        case (false, .single):
            endScreenText.text = "You lose!"
        case (_ , .bot):
            endScreenText.text = "Draw!"
        default:
            break
        }

    }

    @IBAction func back(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
}
