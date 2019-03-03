//
//  PhysicsEngine.swift
//  GameEngine
//
//  Created by Jie Liang Ang on 13/2/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import Foundation

/**
 `PhysicsEngine` provides an environment to simulate a physical system, such as simple object
 physical movement and rigid body dynamics / collision detection.
 `PhysicsEngine` consists of a system of `RigidBody` reacting to each other, and is bounded within a rectangle.
 
 The internal representation of `RigidBody` objects in `PhysicsEngine` is categorized to three
 sections:
 - Stationary bodies: `RigidBody` which position is fixed at all time and can never move
 - Moving bodies: `RigidBody` which are free to move and not affected by gravity, may collide with other bodies
 - Dropping bodies: `RigidBody` which are free falling and affected by gravity
 
 */
public class PhysicsEngine {
    
    public typealias BodyWallHandler = ((RigidBody, Wall) -> Void)
    public typealias BodyBodyHandler = ((RigidBody, RigidBody) -> Void)

    let minX: Double
    let maxX: Double
    let minY: Double
    let maxY: Double
    private var movingBodies = Set<RigidBody>()
    private var stationaryBodies = Set<RigidBody>()
    private var droppingBodies = Set<RigidBody>()

    private let gravity: Vector2

    public init(minX: Double, maxX: Double, minY: Double, maxY: Double, gravity: Vector2) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
        self.gravity = gravity
    }

    /// Adds a stationary body to the system if it is not already present
    /// - Parameter body: `RigidBody` to be added
    public func addStationaryBody(_ body: RigidBody) {
        guard body.velocity == Vector2.null(),
            body.acceleration == Vector2.null() else {
                return
        }
        stationaryBodies.insert(body)
    }

    /// Removes a stationary body from the system
    /// If body does not exist in the system, do nothing
    /// - Parameter body: `RigidBody` to be removed
    public func removeStationaryBody(_ body: RigidBody) {
        stationaryBodies.remove(body)
    }

    /// Adds a moving body to the system if it is not already present
    /// - Parameter body: `RigidBody` to be added
    public func addMovingBody(_ body: RigidBody) {
        guard body.acceleration == Vector2.null() else {
            return
        }
        movingBodies.insert(body)
    }

    /// Removes a moving body from the system
    /// If body does not exist in the system, do nothing
    /// - Parameter body: `RigidBody` to be removed
    public func removeMovingBody(_ body: RigidBody) {
        movingBodies.remove(body)
    }

    /// Adds a dropping body to the system if it is not already present
    /// - Parameter body: `RigidBody` to be added
    public func addDroppingBody(_ body: RigidBody) {
        body.acceleration = gravity
        droppingBodies.insert(body)
    }

    /// Enables gravity to a body in the system
    /// If body does not exist in the system, do nothing
    /// - Parameter body: `RigidBody` to be enabled gravity
    public func dropBody(_ body: RigidBody) {
        body.acceleration = gravity
        if stationaryBodies.contains(body) {
            stationaryBodies.remove(body)
            droppingBodies.insert(body)
        } else if movingBodies.contains(body) {
            movingBodies.remove(body)
            droppingBodies.insert(body)
        }
    }

    /// Removes a dropping body from the system
    /// If body does not exist in the system, do nothing
    /// - Parameter body: `RigidBody` to be removed
    public func removeDroppingBody(_ body: RigidBody) {
        droppingBodies.remove(body)
    }

    /// Update moving and dropping bodies' position and velocity for the next timestep
    public func update(time: Double, movingWithStat: BodyBodyHandler, movingWithMoving: BodyBodyHandler,
                       movingWithWall: BodyWallHandler, droppingWithWall: BodyWallHandler) {
        for body in movingBodies {
            body.update(time: time)
            handleMovingBodyCollision(body: body, movingWithStat: movingWithStat,
                                      movingWithMoving: movingWithMoving, movingWithWall: movingWithWall)
        }
        for body in droppingBodies {
            body.update(time: time)
            handleDroppingBodyCollision(body: body, droppingWithWall: droppingWithWall)
        }
    }

    /// Reset physics engine
    public func reset() {
        movingBodies.removeAll()
        stationaryBodies.removeAll()
        droppingBodies.removeAll()
    }

    // Returns size of stationaryBodies
    public var stationaryBodiesCount: Int {
        return stationaryBodies.count
    }

    // Returns size of movingBodies
    public var movingBodiesCount: Int {
        return movingBodies.count
    }

    // Returns size of droppingBodies
    public var droppingBodesCount: Int {
        return droppingBodies.count
    }

    // Detect and resolve moving body collision with environment
    private func handleMovingBodyCollision(body: RigidBody, movingWithStat: BodyBodyHandler,
                                           movingWithMoving: BodyBodyHandler, movingWithWall: BodyWallHandler) {
        // Detect collision with stationary bubbles
        for stationaryBody in stationaryBodies {
            if hasCollisionBetweenBodies(body, with: stationaryBody) {
                movingWithStat(body, stationaryBody)
                return
            }
        }

        // Detect collision with walls
        for wall in Wall.allCases {
            if hasCollisionWithBounds(body: body, wall: wall) {
                movingWithWall(body, wall)
                break
            }
        }

        // Detect collision with moving bubbles
        for movingBody in movingBodies where body != movingBody {
            if hasCollisionBetweenBodies(body, with: movingBody) {
                movingWithMoving(body, movingBody)
                break
            }
        }
    }

    // Detect and resolve dropping body collision with environment
    // Current version (PS4) does not interact with other bodies.
    private func handleDroppingBodyCollision(body: RigidBody, droppingWithWall: BodyWallHandler) {
        // Detect collision with boundaries
        for wall in Wall.allCases {
            if hasCollisionWithBounds(body: body, wall: wall) {
                droppingWithWall(body, wall)
                break
            }
        }
    }

    // MARK: Collision detection
    // Detect collision between two `RigidBody`
    private func hasCollisionBetweenBodies(_ bodyA: RigidBody, with bodyB: RigidBody) -> Bool {
        switch (bodyA.shape, bodyB.shape) {
        case (Shape.circle(radius: let radiusA), Shape.circle(radius: let radiusB)):
            let bool = bodyA.position.distance(with: bodyB.position) < radiusA + radiusB
            return bool
        }
    }

    // Detect collision of `RigidBody` with physical environment bounds
    private func hasCollisionWithBounds(body: RigidBody, wall: Wall) -> Bool {
        switch body.shape {
        case Shape.circle(radius: let radius):
            switch wall {
            case .right:
                return body.position.xComponent + radius > maxX
            case .left:
                return body.position.xComponent - radius < minX
            case .bottom:
                return body.position.yComponent + radius > maxY
            case .top:
                return body.position.yComponent - radius < minY
            }
        }
    }
}
