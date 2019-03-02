//
//  Player.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 2/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import Foundation
import UIKit
//@IBOutlet var cannonSinglePlayer: UIImageView!
//@IBOutlet var bubbleToShoot: UIImageView!
//@IBOutlet var nextBubble: UIImageView!
//@IBOutlet var secondNextBubble: UIImageView!
//@IBOutlet var cannonBase: UIImageView!
//@IBOutlet var tapSingle: UITapGestureRecognizer!
//@IBOutlet var panSingle: UIPanGestureRecognizer!

class Player {
    var mainView: UIView
    var cannon: UIImageView
    var bubbleToShoot: UIImageView
    var nextBubble: UIImageView
    var secondNextBubble: UIImageView
    var cannonBase: UIImageView
    var tapGestureRecognizer: UITapGestureRecognizer
    var panGestureRecognizer: UIPanGestureRecognizer
    var currentBubbleType: BubbleType {
        didSet {
            bubbleToShoot.image = UIImage(named: ResourceManager.imageName(of: currentBubbleType))
        }
    }
    var nextBubbleType: BubbleType {
        didSet {
            nextBubble.image = UIImage(named: ResourceManager.imageName(of: nextBubbleType))
        }
    }
    var secondNextBubbleType: BubbleType {
        didSet {
            secondNextBubble.image = UIImage(named: ResourceManager.imageName(of: secondNextBubbleType))
        }
    }
    var canShoot = true
    let nextBubblePosition: CGPoint
    let secondNextBubblePosition: CGPoint

    init(mainView: UIView, cannon: UIImageView, bubbleToShoot: UIImageView, nextBubble: UIImageView,
         secondNextBubble: UIImageView, cannonBase: UIImageView, tapGestureRecognizer: UITapGestureRecognizer,
         panGestureRecognizer: UIPanGestureRecognizer) {
        self.mainView = mainView
        self.cannon = cannon
        self.bubbleToShoot = bubbleToShoot
        self.nextBubble = nextBubble
        self.secondNextBubble = secondNextBubble
        self.cannonBase = cannonBase
        self.tapGestureRecognizer = tapGestureRecognizer
        self.panGestureRecognizer = panGestureRecognizer
        self.currentBubbleType = BubbleType.randomType()
        self.nextBubbleType = BubbleType.randomType()
        self.secondNextBubbleType = BubbleType.randomType()
        self.nextBubblePosition = CGPoint(x: nextBubble.layer.position.x,
                                          y: nextBubble.layer.position.y)
        self.secondNextBubblePosition = CGPoint(x: secondNextBubble.layer.position.x,
                                                y: secondNextBubble.layer.position.y)
    }

    func updateLoadedBubbles(set: Set<BubbleType>) {
        if !set.contains(currentBubbleType) {
            currentBubbleType = set.randomElement() ?? BubbleType.randomType()
        }
        if !set.contains(nextBubbleType) {
            nextBubbleType = set.randomElement() ?? BubbleType.randomType()
        }
        if !set.contains(secondNextBubbleType) {
            secondNextBubbleType = set.randomElement() ?? BubbleType.randomType()
        }
    }

    func resetLoadedBubbles(set: Set<BubbleType>) {
        currentBubbleType = set.randomElement() ?? BubbleType.randomType()
        nextBubbleType = set.randomElement() ?? BubbleType.randomType()
        secondNextBubbleType = set.randomElement() ?? BubbleType.randomType()
    }
}
