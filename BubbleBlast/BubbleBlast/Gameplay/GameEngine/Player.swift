//
//  Player.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 2/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import Foundation
import UIKit

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
    var trajectory: TrajectoryPath
    var score: UICountingLabel
    var bubblesLeft: CounterLabel

    var numOfBubblesLeft: Int {
        return bubblesLeft.bubblesLeft
    }

    init(mainView: UIView, cannon: UIImageView, bubbleToShoot: UIImageView, nextBubble: UIImageView,
         secondNextBubble: UIImageView, cannonBase: UIImageView, tapGestureRecognizer: UITapGestureRecognizer,
         panGestureRecognizer: UIPanGestureRecognizer, trajectory: TrajectoryPath, score: UICountingLabel,
         bubblesLeft: CounterLabel) {
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
        self.trajectory = trajectory
        self.score = score
        self.bubblesLeft = bubblesLeft
        //drawCannon()
    }

    func enable() {
        mainView.isHidden = false
        tapGestureRecognizer.isEnabled = true
        panGestureRecognizer.isEnabled = true
    }

    func disable() {
        mainView.isHidden = true
        tapGestureRecognizer.isEnabled = false
        panGestureRecognizer.isEnabled = false
    }

    func swap() {
        let tempType = currentBubbleType
        currentBubbleType = nextBubbleType
        nextBubbleType = tempType
    }

    func decrementBubble() {
        bubblesLeft.decrement()
    }

     func drawCannon() {
        guard let overallImage = UIImage(named: "cannon.png") else {
            return
        }
        let overallImageHeight = overallImage.size.height
        let overallImageWidth = overallImage.size.width

        let cannonHeight = overallImageHeight / 2 * 2
        let cannonWidth = overallImageWidth / 6 * 2

        var cannonArray = [UIImage]()

        guard let cgImage = overallImage.cgImage else {
            return
        }
        for index in 0..<12 {
            let rect = CGRect(x: cannonWidth * CGFloat(index % 6),
                              y: cannonHeight * CGFloat(index / 6),
                              width: cannonWidth,
                              height: cannonHeight)

            guard let croppedCannon = cgImage.cropping(to: rect) else {
                continue
            }
            cannonArray.append(UIImage(cgImage: croppedCannon))
        }

        cannon.image = cannonArray[0]
        cannon.animationImages = cannonArray
        cannon.animationDuration = 1/4
        cannon.animationRepeatCount = 1
    }

    func loadBubble(nextType: BubbleType) {

//        let next = CGPoint(x: nextBubble.center.x, y: nextBubble.center.y)
//        let secondNext = CGPoint(x: secondNextBubble.center.x, y: secondNextBubble.center.y)

//        canShoot = false
//        bubbleToShoot.image = nil
//        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
//            self.nextBubble.layer.position = self.bubbleToShoot.layer.position
//            self.secondNextBubble.layer.position = next
//        }, completion: { _ in
//            self.currentBubbleType = self.nextBubbleType
//            self.nextBubbleType = self.secondNextBubbleType
//            self.secondNextBubbleType = nextType
//            self.nextBubble.layer.position = next
//
//            self.secondNextBubble.alpha = 0.0
//            self.secondNextBubble.layer.position = secondNext
//            UIView.animate(withDuration: 0.3, animations: {
//                self.secondNextBubble.alpha = 0.5
//            })
//            self.canShoot = true
//        })
        currentBubbleType = nextBubbleType
        nextBubbleType = secondNextBubbleType
        secondNextBubbleType = nextType
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

    func pauseLoadedBubbles() {
        currentBubbleType = .indestructible
        nextBubbleType = .indestructible
        secondNextBubbleType = .indestructible
    }
}
