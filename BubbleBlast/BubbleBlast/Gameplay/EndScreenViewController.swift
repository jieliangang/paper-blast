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
    @IBOutlet var endScreenImage: UIImageView!

    var result: (Bool, PlayerType) = (false, .single)

    let successImage = UIImage(named: "trophy.png")
    let failImage = UIImage(named: "crying.png")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 5.0

        switch result {
        case (true, .single):
            endScreenText.text = "You win!"
            endScreenImage.image = successImage
        case (true, .one), (false, .two):
            endScreenText.text = "Player One win!"
            endScreenImage.image = successImage
        case (true, .two), (false, .one):
            endScreenText.text = "Player Two win!"
            endScreenImage.image = successImage
        case (false, .single):
            endScreenText.text = "You lose!"
            endScreenImage.image = UIImage(named: "crying")
        case (_, .bot):
            endScreenText.text = "Draw!"
            endScreenImage.image = successImage
        }
    }

    @IBAction func back(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
    }
}
