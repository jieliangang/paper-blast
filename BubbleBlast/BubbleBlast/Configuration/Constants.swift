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
        static let numOfRows = 14
        static let numOfBubblesInEvenRow = 12
        static let numOfBubblesInOddRow = numOfBubblesInEvenRow - 1
        static let numOfBubblesInRowSet = numOfBubblesInEvenRow + numOfBubblesInOddRow
        static let maxNumOfBubbles = numOfBubblesInRowSet * numOfRows / 2
        static let numOfBubblesToPop = 3
    }
}
