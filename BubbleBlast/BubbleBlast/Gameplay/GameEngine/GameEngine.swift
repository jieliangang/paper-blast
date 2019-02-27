//
//  GameEngine.swift
//  GameEngine
//
//  Created by Jie Liang Ang on 13/2/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import PhysicsEngine
import Foundation
import UIKit

/**
 `GameEngine` handles game logic and collision resolution.
 
 For efficient handling and rendering of game objects state and animation,
 internal representation is categorized to three sections:
 
 - StationaryBubbleObjects: Represents the bubble on the isometric grid based on grid index
 - MovingBubbleObjects: Represents bubble which are being shot
 - DroppingBubbleObjects: Represents disconnected bubble which are dropping from the grid for animation
 
 */
class GameEngine {

    private var physicsEngine: PhysicsEngine
    private(set) var stationaryBubbleObjects: [Int: BubbleObject] = [:]
    private(set) var movingBubbleObjects = Set<BubbleObject>()
    private(set) var droppingBubbleObjects = Set<BubbleObject>()

    // Maps `RigidBody` in `PhysicsEngine` to `BubbleObject`
    private var dictionary: [ObjectIdentifier: BubbleObject] = [:]
    // Center positions of cells in the isometric bubble grid
    private var gridPositions: [Vector2]

    init(minX: Double, maxX: Double, minY: Double, maxY: Double, gridPositions: [Vector2]) {
        self.gridPositions = gridPositions
        physicsEngine = PhysicsEngine(minX: minX, maxX: maxX, minY: minY, maxY: maxY,
                                      gravity: Constants.Physics.gravity)

        // Collision resolution
        physicsEngine.resolveMovingBodyCollisionWithWall = resolveMovingObjectCollisionWithWall
        physicsEngine.resolveMovingBodyCollisionWithStatBody = resolveCollisionWithStationaryObject
        physicsEngine.resolveDroppingBodyCollisionWithWall = resolveDroppingObjectCollisionWithWall
    }

    /// Update state of game and physics engine
    func update() {
        physicsEngine.update(time: Constants.Game.fps)
    }

    /// Shoot bubble in the game
    /// - Parameters:
    ///     - originLocation: cannon location
    ///     - tapLocation: input location which indicates cannon/bubble direction
    ///     - bubbleSize: size of bubble being shot
    ///     - currentPlayBubbleType: type of bubble being shot
    func shootBubble(originLocation: CGPoint, tapLocation: CGPoint,
                     bubbleSize: CGFloat, currentPlayBubbleType: BubbleType) {
        let xDistance = tapLocation.x - originLocation.x
        let yDistance = tapLocation.y - originLocation.y
        guard yDistance < 0 else {
            return
        }
        let velocityMagnitude = Constants.Physics.velocityMagnitude
        let distance = sqrt(pow(xDistance, 2) + pow(yDistance, 2))

        insertMovingBubble(position: Vector2(xCGComponent: originLocation.x,
                                             yCGComponent: originLocation.y),
                           velocity: Vector2(xComponent: velocityMagnitude * Double(xDistance / distance),
                                             yComponent: velocityMagnitude * Double(yDistance / distance)),
                           radius: Double(bubbleSize/2),
                           type: currentPlayBubbleType)
    }

    // MARK: Basic actions
    /// Inserts a moving bubble object in the game and updates physics engine
    /// - Parameters:
    ///     - position: initial position of bubble
    ///     - velocity: initial velocity of bubble
    ///     - radius: radius of bubble
    ///     - type: type of bubble
    private func insertMovingBubble(position: Vector2, velocity: Vector2, radius: Double, type: BubbleType) {
        let object = BubbleObject(type: type, position: position, velocity: velocity,
                                  shape: Shape.circle(radius: radius))

        movingBubbleObjects.insert(object)
        physicsEngine.addMovingBody(object.body)
        dictionary[ObjectIdentifier(object.body)] = object
    }

    /// Inserts a stationary bubble object in the bubble grid and updates physics engine.
    /// Handles subsequent consequence due to insertion of bubble in the game
    /// - Parameters:
    ///     - radius: radius of bubble
    ///     - type: type of bubble
    ///     - index: index in bubble grid
    private func insertStationaryBubble(radius: Double, type: BubbleType, index: Int) {
        let object = BubbleObject(type: type, position: gridPositions[index], shape: Shape.circle(radius: radius))

        stationaryBubbleObjects[index] = object
        physicsEngine.addStationaryBody(object.body)
        dictionary[ObjectIdentifier(object.body)] = object

        // Handles different bubble when placed according to the type
        switch type {
        case .colorBlue, .colorGreen, .colorYellow, .colorRed:
            // Slight delay added to allow bubble to be in position before being removed if to be removed
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: {
                self.removeAdjacentSimilarColorBubbles(of: index)
                self.dropUnconnectedObjects()
            })
        // add more cases in the future for different type to act differently
        }
    }

    /// Removes a moving bubble object in the game and updates physics engine
    /// - Parameters:
    ///     - object: moving bubble object to be removed
    private func removeMovingObject(_ object: BubbleObject) {
        movingBubbleObjects.remove(object)
        physicsEngine.removeMovingBody(object.body)
        dictionary.removeValue(forKey: ObjectIdentifier(object.body))
    }

    /// Removes a stationary bubble object from the game grid and updates physics engine
    /// - Parameters:
    ///     - object: stationary bubble object to be removed
    private func removeStationaryObject(_ index: Int) {
        guard let object = stationaryBubbleObjects[index] else {
            return
        }
        stationaryBubbleObjects.removeValue(forKey: index)
        physicsEngine.removeStationaryBody(object.body)
        dictionary.removeValue(forKey: ObjectIdentifier(object.body))
        reloadCellAt(index)
    }

    /// Drops a stationary bubble object from the game grid and updates physics engine
    /// - Parameter object: stationary bubble object to be dropped
    private func dropStationaryObjectFromGrid(index: Int) {
        guard let object = stationaryBubbleObjects[index] else {
            return
        }
        stationaryBubbleObjects.removeValue(forKey: index)
        droppingBubbleObjects.insert(object)
        physicsEngine.dropBody(object.body)

        // Set initial velocity of dropping object to a random upwards velocity
        object.body.velocity = Vector2(xComponent: Double.random(in: -200...200),
                                       yComponent: Double.random(in: -150...(-100)))
        reloadCellAt(index)
    }

    /// Send notification to controller to reload cell in bubble collection view
    private func reloadCellAt(_ index: Int) {
        let indexDict: [String: Int] = ["index": index]
        NotificationCenter.default.post(name: NSNotification.Name("reloadCell"), object: self, userInfo: indexDict)
    }

    /// Clear all stationary bubbles and send notification to controller to inform game over
    private func gameOver() {
        dropEverything()
        NotificationCenter.default.post(name: NSNotification.Name("gameOver"), object: self, userInfo: nil)
    }

    // MARK: Gameplay actions and logic
    /// Remove identically-colored and connected bubbles from root bubble
    /// if group of bubbles exceed certain amount
    /// - Parameter index: index of root bubble
    private func removeAdjacentSimilarColorBubbles(of index: Int) {
        let similarGroupIndices = getAdjacentSimilarColorBubbles(of: index)
        guard similarGroupIndices.count >= Constants.Game.numOfBubblesToPop else {
            return
        }
        for index in similarGroupIndices {
            removeStationaryObject(index)
        }
    }

    /// Drops unconnected bubbles from the top wall
    private func dropUnconnectedObjects() {
        let attachedObjects = findAttachedBubbles()
        for index in stationaryBubbleObjects.keys where !attachedObjects.contains(index) {
            dropStationaryObjectFromGrid(index: index)
        }
    }

    /// Drop all connected/stationary bubbles in the game
    func dropEverything() {
        for index in stationaryBubbleObjects.keys {
            dropStationaryObjectFromGrid(index: index)
        }
    }

    /// Obtain indices of own and adjacent bubbles with same colour
    /// - Parameter index: index of root bubble
    private func getAdjacentSimilarColorBubbles(of index: Int) -> [Int] {
        var adjacentBubblesIndex = [Int]()
        var visited = Set<Int>()
        var queue = Queue<Int>()
        queue.enqueue(index)
        visited.insert(index)
        adjacentBubblesIndex.append(index)

        // BFS search to look for adjacent bubbles with same colour
        while let currIndex = queue.dequeue() {
            for neighborIndex in neighbor(of: currIndex) {
                guard neighborIndex >= 0, neighborIndex < Constants.Game.maxNumOfBubbles else {
                    continue
                }
                guard !visited.contains(neighborIndex) else {
                    continue
                }
                visited.insert(neighborIndex)
                guard let object1 = stationaryBubbleObjects[index],
                    let object2 = stationaryBubbleObjects[neighborIndex] else {
                        continue
                }
                guard object1.type == object2.type else {
                    continue
                }
                queue.enqueue(neighborIndex)
                adjacentBubblesIndex.append(neighborIndex)
            }
        }
        return adjacentBubblesIndex
    }

    /// Search for bubbles which are attached to the top wall
    private func findAttachedBubbles() -> Set<Int> {
        var visited = Set<Int>()
        var queue = Queue<Int>()

        for root in 0..<Constants.Game.numOfBubblesInEvenRow where stationaryBubbleObjects.keys.contains(root) {
            queue.enqueue(root)
            visited.insert(root)
        }
        while let currIndex = queue.dequeue() {
            for neighborIndex in neighbor(of: currIndex) {
                guard stationaryBubbleObjects.keys.contains(neighborIndex) else {
                    continue
                }
                guard !visited.contains(neighborIndex) else {
                    continue
                }
                queue.enqueue(neighborIndex)
                visited.insert(neighborIndex)
            }
        }
        return visited
    }

    /// Neighbor index of a game object in a hexagonal isometric grid
    private func neighbor(of index: Int) -> [Int] {
        // even row, leftest
        if index % Constants.Game.numOfBubblesInRowSet == 0 {
            return [index - Constants.Game.numOfBubblesInOddRow,
                    index + 1, index + Constants.Game.numOfBubblesInEvenRow]
        }
        // even row, rightest
        else if index % Constants.Game.numOfBubblesInRowSet == Constants.Game.numOfBubblesInOddRow {
            return [index - Constants.Game.numOfBubblesInEvenRow,
                    index - 1,
                    index + Constants.Game.numOfBubblesInOddRow]
        }
        // odd row, leftest
        else if index % Constants.Game.numOfBubblesInRowSet == Constants.Game.numOfBubblesInEvenRow {
            return [index - Constants.Game.numOfBubblesInEvenRow,
                    index - Constants.Game.numOfBubblesInOddRow,
                    index + 1,
                    index + Constants.Game.numOfBubblesInOddRow,
                    index + Constants.Game.numOfBubblesInEvenRow]
        }
        // odd row, rightest
        else if index % Constants.Game.numOfBubblesInRowSet == (Constants.Game.numOfBubblesInRowSet - 1) {
            return [index - Constants.Game.numOfBubblesInEvenRow,
                    index - Constants.Game.numOfBubblesInOddRow,
                    index - 1,
                    index + Constants.Game.numOfBubblesInOddRow,
                    index + Constants.Game.numOfBubblesInEvenRow]
        }
        // bubbles not on the extreme row edges
        else {
            return [index - Constants.Game.numOfBubblesInEvenRow,
                    index - Constants.Game.numOfBubblesInOddRow,
                    index - 1,
                    index + 1,
                    index + Constants.Game.numOfBubblesInOddRow,
                    index + Constants.Game.numOfBubblesInEvenRow]
        }
    }
}

// MARK: PS4 - Problem 1.2
extension GameEngine {
    func removeAllBubblesOfType(_ typeToRemove: BubbleType) {
        for (index, bubble) in stationaryBubbleObjects where bubble.type == typeToRemove {
            removeStationaryObject(index)
        }
        dropUnconnectedObjects()
    }
}

// MARK: Collision resolution
extension GameEngine {
    /// Resolve collision of a moving object with a stationary object
    private func resolveCollisionWithStationaryObject(_ body1: RigidBody, with body2: RigidBody) {
        guard let object1 = dictionary[ObjectIdentifier(body1)] else {
            print("mapping error!")
            return
        }
        guard let object2 = dictionary[ObjectIdentifier(body2)] else {
            print("mapping error!")
            return
        }
        guard movingBubbleObjects.contains(object1) else {
            return
        }
        guard stationaryBubbleObjects.values.contains(object2) else {
            return
        }

        switch (body1.shape, body2.shape) {
        case (Shape.circle, Shape.circle):
            connectToNearestPosition(object1)
        }
    }

    /// Resolve collision of a moving object with walls/bounds
    private func resolveMovingObjectCollisionWithWall(_ body: RigidBody, with wall: Wall) {
        guard let object = dictionary[ObjectIdentifier(body)] else {
            print("mapping error!")
            return
        }
        switch wall {
        case .top:
            switch body.shape {
            case Shape.circle:
                connectToNearestPosition(object)
            }
        case .bottom:
            // remove moving object when reached bottom of screen
            self.movingBubbleObjects.remove(object)
            self.physicsEngine.removeMovingBody(object.body)
            self.dictionary.removeValue(forKey: ObjectIdentifier(object.body))
        case .left, .right:
            resolveBoundCollisionBetween(body: body, wall: wall)
        }
    }

    /// Resolve collision of a dropping object with walls/bounds
    private func resolveDroppingObjectCollisionWithWall(_ body: RigidBody, with wall: Wall) {
        guard let object = dictionary[ObjectIdentifier(body)] else {
            print("mapping error")
            return
        }
        switch wall {
        case .bottom:
            self.droppingBubbleObjects.remove(object)
            self.physicsEngine.removeDroppingBody(object.body)
            self.dictionary.removeValue(forKey: ObjectIdentifier(object.body))
        case .top, .left, .right:
            resolveBoundCollisionBetween(body: body, wall: wall)
        }
    }

    /// Snaps bubble to the closest empty cell when it collides with an existing bubble
    /// - Parameter object: bubble which collides and to be positioned
    private func connectToNearestPosition(_ object: BubbleObject) {
        guard let index = findNearestPositionIndex(object.body.position) else {
            return
        }
        switch object.body.shape {
        case Shape.circle(radius: let radius):
            insertStationaryBubble(radius: radius,
                                   type: object.type, index: index)
            removeMovingObject(object)
        }
        reloadCellAt(index)
        // Detect for game over
        if index >= Constants.Game.maxNumOfBubbles - Constants.Game.numOfBubblesInOddRow {
            gameOver()
        }
    }

    /// Find closest empty cell when bubble collides with an existing bubble
    private func findNearestPositionIndex(_ bodyPosition: Vector2) -> Int? {
        var nearestIndex: Int?
        var nearestDistance = Double.greatestFiniteMagnitude
        for (index, position) in gridPositions.enumerated() {
            guard !stationaryBubbleObjects.keys.contains(index) else {
                continue
            }
            let distance = bodyPosition.distance(with: position)
            if distance < nearestDistance {
                nearestIndex = index
                nearestDistance = distance
            }
        }
        return nearestIndex
    }

    /// Default collision resolution of `RigidBody` with physical environment bounds
    private func resolveBoundCollisionBetween(body: RigidBody, wall: Wall) {
        switch body.shape {
        case Shape.circle:
            switch wall {
            case .right, .left:
                body.velocity.xComponent *= -1
            case .top, .bottom:
                body.velocity.yComponent *= -1
            }
        }
    }

    // Not used in PS4. Prepared for PS5.
    // Reference: https://en.wikipedia.org/wiki/Elastic_collision#Two-dimensional_collision_with_two_moving_objects
    private func resolveElasticCollisionBetween(_ bodyA: RigidBody, with bodyB: RigidBody) {
        let velocityDifference = bodyA.velocity - bodyB.velocity
        let distanceDifference = bodyA.position - bodyB.position

        // Collide only if bodies are moving towards each other
        guard velocityDifference.dot(distanceDifference) < 0 else {
            return
        }

        // Intermediary results based on collision resolution equation
        let massRatio = 2 * bodyA.mass / (bodyA.mass + bodyB.mass)
        let intermediaryResultA = massRatio * velocityDifference.dot(distanceDifference) /
            distanceDifference.dot(distanceDifference)
        let intermediaryResultB = massRatio * (-velocityDifference).dot(-distanceDifference) /
            (-distanceDifference).dot(-distanceDifference)

        let resultantVelocityA = bodyA.velocity - distanceDifference * intermediaryResultA
        let resultantVelocityB = bodyB.velocity + distanceDifference * intermediaryResultB

        bodyA.velocity = resultantVelocityA
        bodyB.velocity = resultantVelocityB
    }
}
