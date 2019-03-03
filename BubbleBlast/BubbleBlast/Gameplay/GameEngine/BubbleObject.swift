//
//  BubbleObject.swift
//  GameEngine
//
//  Created by Jie Liang Ang on 15/2/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import PhysicsEngine
import Foundation

/**
 Representation of a bubble object in the game.
 Consists of a `RigidBody`, its physical representation in the `PhysicsEngine`
 and the bubble type
 */
class BubbleObject {

    let body: RigidBody
    var type: BubbleType
    var player: PlayerType

    init(type: BubbleType, position: Vector2, shape: Shape, player: PlayerType) {
        self.type = type
        self.body = RigidBody(position: position, shape: shape)
        self.player = player
    }

    init(type: BubbleType, position: Vector2, velocity: Vector2, shape: Shape, player: PlayerType) {
        self.type = type
        self.body = RigidBody(position: position, velocity: velocity, shape: shape)
        self.player = player
    }
}

// MARK: Hashable
extension BubbleObject: Hashable {
    static func == (lhs: BubbleObject, rhs: BubbleObject) -> Bool {
        return lhs.body == rhs.body &&
            lhs.type == rhs.type &&
            lhs.player == rhs.player
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(body)
        hasher.combine(type)
        hasher.combine(player)
    }
}
