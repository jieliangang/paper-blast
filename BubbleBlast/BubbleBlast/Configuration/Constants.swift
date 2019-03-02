//
//  Constants.swift
//  GameEngine
//
//  Created by Jie Liang Ang on 15/2/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import Foundation
import PhysicsEngine

struct Constants {
    struct Physics {
        static let velocityMagnitude = 1200.0
        static let gravity = Vector2(xComponent: 0, yComponent: 800)
        static let nullVector = Vector2(xComponent: 0, yComponent: 0)
    }
    struct Game {
        static let fps = 1.0/60
        static let timestep = 1.0/60
        static let numOfRows = LevelDesigner.numOfRows + 2
        static let numOfBubblesInEvenRow = 12
        static let numOfBubblesInOddRow = numOfBubblesInEvenRow - 1
        static let numOfBubblesInRowSet = numOfBubblesInEvenRow + numOfBubblesInOddRow
        static let maxNumOfBubblesInHex = numOfBubblesInRowSet * numOfRows / 2 
        static let maxNumOfBubblesInRect = numOfRows * numOfBubblesInEvenRow
        static let numOfBubblesToPop = 3
        static var randomDroppingInitialVelocity: Vector2 {
            return Vector2(xComponent: Double.random(in: -200...200),
                           yComponent: Double.random(in: -150...(-100)))
        }
        static let cannonAnimationTime = 1/4
    }
    struct LevelDesigner {
        static let numOfRows = 12
        static let totalNumOfBubblesInHex = Game.numOfBubblesInRowSet * (numOfRows / 2) +
                                            Game.numOfBubblesInOddRow * (numOfRows % 2)
        static let totalNumOfBubblesInRect = Game.numOfBubblesInEvenRow * numOfRows
    }
}
