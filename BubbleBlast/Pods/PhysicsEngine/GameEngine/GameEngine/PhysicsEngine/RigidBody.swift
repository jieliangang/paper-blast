//
//  RigidBody.swift
//  GameEngine
//
//  Created by Jie Liang Ang on 16/2/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import Foundation

/**
 `RigidBody` represents a physics object in the `PhysicsEngine`, which is a solid
 body with no deformation. Considered as a continuous distribution of mass.
 */
public class RigidBody {
    public var position: Vector2
    public var velocity = Vector2.null()
    public var acceleration = Vector2.null()
    public let shape: Shape
    public var mass = 1.0

    public init(position: Vector2, shape: Shape) {
        self.position = position
        self.shape = shape
    }

    public init(position: Vector2, velocity: Vector2, shape: Shape) {
        self.position = position
        self.shape = shape
        self.velocity = velocity
    }

    public init(position: Vector2, velocity: Vector2, acceleration: Vector2, shape: Shape, mass: Double) {
        self.position = position
        self.shape = shape
        self.velocity = velocity
        self.acceleration = acceleration
        self.mass = mass
    }

    /// Update rigid body's position and velocity for the next timestep
    public func update(time: Double) {
        velocity += Vector2(xComponent: acceleration.xComponent * time,
                            yComponent: acceleration.yComponent * time)

        position += Vector2(xComponent: velocity.xComponent * time,
                            yComponent: velocity.yComponent * time)
    }
}

// MARK: Hashable
extension RigidBody: Hashable {
    // `RigidBody` instances are identified by the unique instance itself
    public static func == (lhs: RigidBody, rhs: RigidBody) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
