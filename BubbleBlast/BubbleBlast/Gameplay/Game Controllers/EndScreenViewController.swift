//
//  EndScreenViewController.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 3/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import UIKit

class EndScreenViewController: UIViewController {

    @IBOutlet var popUpView: UIView!
    @IBOutlet private var endScreenText: UILabel!
    @IBOutlet private var endScreenImage: UIImageView!
    @IBOutlet private var finalScore: UICountingLabel!

    var result = Result(didWin: true, player: .bot, score: 0)

    let successImage = UIImage(named: "trophy.png")
    let failImage = UIImage(named: "crying.png")

    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = popUpView.frame.width / 8

        switch (result.didWin, result.player) {
        case (true, .single):
            endScreenText.text = "You win!"
            endScreenImage.image = successImage
            finalScore.count(fromValue: 0, toValue: Float(result.score), withDuration: 1, animationType: .easeIn)
        case (true, .one), (false, .two):
            endScreenText.text = "Player One win!"
            endScreenImage.image = successImage
            finalScore.count(fromValue: 0, toValue: Float(result.score), withDuration: 1, animationType: .easeIn)
        case (true, .two), (false, .one):
            endScreenText.text = "Player Two win!"
            endScreenImage.image = successImage
            finalScore.count(fromValue: 0, toValue: Float(result.score), withDuration: 1, animationType: .easeIn)
        case (false, .single):
            endScreenText.text = "You lose!"
            endScreenImage.image = failImage
        case (_, .bot):
            endScreenText.text = "Draw!"
            endScreenImage.image = successImage
            finalScore.count(fromValue: 0, toValue: Float(result.score), withDuration: 1, animationType: .easeIn)
        }
    }

    @IBAction func back(_ sender: UIButton) {
        ResourceManager.transition()
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
    }
}
