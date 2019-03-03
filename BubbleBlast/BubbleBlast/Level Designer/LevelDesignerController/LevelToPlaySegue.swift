//
//  LevelToPlaySegue.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 27/2/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import UIKit

class LevelToPlaySegue: UIStoryboardSegue {
    override func perform() {
        shift()
    }

    func shift() {
        let toViewController = self.destination
        let fromViewController = self.source

        let containerView = fromViewController.view.superview
        let originalCenter = fromViewController.view.center

        toViewController.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        toViewController.view.center = originalCenter

        containerView?.addSubview(toViewController.view)

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            toViewController.view.transform = CGAffineTransform.identity
        }, completion: { _ in
            fromViewController.present(toViewController, animated: false, completion: nil)
        })
    }
}
