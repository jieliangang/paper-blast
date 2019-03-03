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

    // Maps `BubbleObject` to index in grid
    private(set) var stationaryBubbleObjectsMap: [BubbleObject: Int] = [:]
    // Maps `RigidBody` in `PhysicsEngine` to `BubbleObject`
    private var dictionary: [ObjectIdentifier: BubbleObject] = [:]
    // Center positions of cells in the isometric bubble grid
    private var gridPositions: [Vector2]

    var bubblesLeft: Set<BubbleType> {
        return Set(stationaryBubbleObjects.values
            .map { $0.type }
            .filter { $0.isColor()})
    }

    func randomBubbleType() -> BubbleType {
        return bubblesLeft.randomElement() ?? BubbleType.colorRed
    }

    let numOfBubblesInEvenRow = Constants.Game.numOfBubblesInEvenRow
    let numOfBubblesInOddRow: Int
    let maxNumOfBubblesInGame: Int
    let isHexagonal: Bool

    let reloadCellNotification = NSNotification.Name("reloadCell")
    let moveCellNotification = NSNotification.Name("moveCell")

    init(minX: Double, maxX: Double, minY: Double, maxY: Double,
         gridPositions: [Vector2], game: GameBubbleSet, maxNumOfBubbles: Int) {
        self.gridPositions = gridPositions
        physicsEngine = PhysicsEngine(minX: minX, maxX: maxX, minY: minY, maxY: maxY,
                                      gravity: Constants.Physics.gravity)

        isHexagonal = game.isHexagonal
        numOfBubblesInOddRow = isHexagonal ? Constants.Game.numOfBubblesInOddRow
                                           : Constants.Game.numOfBubblesInEvenRow
        maxNumOfBubblesInGame = maxNumOfBubbles

        // Initialise stationaryBubbleObjects
        let radius = (maxX - minX) / Double(Constants.Game.numOfBubblesInEvenRow) / 2
        for (index, type) in game.bubbleTypes.enumerated() where type != .empty {
            let object = BubbleObject(type: type, position: gridPositions[index],
                                      shape: Shape.circle(radius: radius), player: PlayerType.bot)
            stationaryBubbleObjects[index] = object
            stationaryBubbleObjectsMap[object] = index
            physicsEngine.addStationaryBody(object.body)
            dictionary[ObjectIdentifier(object.body)] = object
        }
        dropUnconnectedObjects(player: .bot)
    }

    /// Update state of game and physics engine
    func update() {
        physicsEngine.update(time: Constants.Game.fps,
                             movingWithStat: resolveCollisionWithStationaryObject(_:with:),
                             movingWithMoving: resolveElasticCollisionBetween(_:with:),
                             movingWithWall: resolveMovingObjectCollisionWithWall(_:with:),
                             droppingWithWall: resolveDroppingObjectCollisionWithWall(_:with:))
    }

    /// Shoot bubble in the game
    /// - Parameters:
    ///     - originLocation: cannon location
    ///     - tapLocation: input location which indicates cannon/bubble direction
    ///     - bubbleSize: size of bubble being shot
    ///     - currentPlayBubbleType: type of bubble being shot
    func shootBubble(originLocation: CGPoint, tapLocation: CGPoint,
                     bubbleSize: CGFloat, currentPlayBubbleType: BubbleType,
                     player: PlayerType) {
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
                           type: currentPlayBubbleType,
                           player: player)
    }
}

// MARK: Basic actions
extension GameEngine {

    /// Inserts a moving bubble object in the game and updates physics engine
    /// - Parameters:
    ///     - position: initial position of bubble
    ///     - velocity: initial velocity of bubble
    ///     - radius: radius of bubble
    ///     - type: type of bubble
    private func insertMovingBubble(position: Vector2, velocity: Vector2, radius: Double,
                                    type: BubbleType, player: PlayerType) {
        let object = BubbleObject(type: type, position: position, velocity: velocity,
                                  shape: Shape.circle(radius: radius),
                                  player: player)

        movingBubbleObjects.insert(object)
        physicsEngine.addMovingBody(object.body)
        dictionary[ObjectIdentifier(object.body)] = object
    }

    /// Removes a moving bubble object in the game and updates physics engine
    /// - Parameters:
    ///     - object: moving bubble object to be removed
    private func removeMovingObject(_ object: BubbleObject) {
        movingBubbleObjects.remove(object)
        physicsEngine.removeMovingBody(object.body)
        dictionary.removeValue(forKey: ObjectIdentifier(object.body))
    }

    /// Inserts a stationary bubble object in the bubble grid and updates physics engine.
    /// Handles subsequent consequence due to insertion of bubble in the game
    /// - Parameters:
    ///     - radius: radius of bubble
    ///     - type: type of bubble
    ///     - index: index in bubble grid
    private func insertStationaryBubble(radius: Double, type: BubbleType, index: Int) {
        let object = BubbleObject(type: type, position: gridPositions[index],
                                  shape: Shape.circle(radius: radius), player: PlayerType.bot)
        stationaryBubbleObjects[index] = object
        stationaryBubbleObjectsMap[object] = index
        physicsEngine.addStationaryBody(object.body)
        dictionary[ObjectIdentifier(object.body)] = object
    }

    /// Removes a stationary bubble object from the game grid and updates physics engine
    /// - Parameters:
    ///     - object: stationary bubble object to be removed
    private func removeStationaryObject(_ index: Int, _ player: PlayerType) {
        guard let object = stationaryBubbleObjects[index] else {
            return
        }
        object.player = player
        // Remove object
        self.stationaryBubbleObjects.removeValue(forKey: index)
        self.stationaryBubbleObjectsMap.removeValue(forKey: object)
        self.physicsEngine.removeStationaryBody(object.body)
        self.dictionary.removeValue(forKey: ObjectIdentifier(object.body))
        self.popCell(type: object.type, playerId: player)

        // Handle triggering of power bubbles
        switch object.type {
        case .bomb: removeSurroundingBubbles(index, player)
        case .lightning: removeRow(index, player)
        default: break
        }
    }

    /// Drops a stationary bubble object from the game grid and updates physics engine
    /// - Parameter object: stationary bubble object to be dropped
    private func dropStationaryObjectFromGrid(index: Int, player: PlayerType) {
        guard let object = stationaryBubbleObjects[index] else {
            return
        }
        object.player = player
        stationaryBubbleObjects.removeValue(forKey: index)
        stationaryBubbleObjectsMap.removeValue(forKey: object)
        droppingBubbleObjects.insert(object)
        physicsEngine.dropBody(object.body)

        // Set initial velocity of dropping object to a random upwards velocity
        object.body.velocity = Constants.Game.randomDroppingInitialVelocity
        reloadCellAt(index)
    }

    /// Send notification to controller to reload cell in bubble collection view
    private func reloadCellAt(_ index: Int) {
        NotificationCenter.default.post(name: reloadCellNotification, object: nil, userInfo: ["index": index])
    }

    /// Send notification to controller to reload cell in bubble collection view
    private func popCell(type: BubbleType, playerId: PlayerType) {
        NotificationCenter.default.post(name: Constants.NotificationName.popCell,
                                        object: nil, userInfo: ["type": type, "playerId": playerId])
    }

    /// Clear all stationary bubbles and send notification to controller to inform game over
    private func gameOver(_ loser: PlayerType) {
        dropEverything()

        NotificationCenter.default.post(name: NSNotification.Name("gameOver"), object: nil, userInfo: ["loser": loser])
    }

    private func noBubblesLeft() {
        dropEverything()
        NotificationCenter.default.post(name: NSNotification.Name("noBubblesLeft"), object: nil)
    }

    private func moveCell(_ center: CGPoint, _ type: BubbleType, _ final: CGPoint) {
        NotificationCenter.default.post(name: moveCellNotification, object: nil,
                                        userInfo: ["center": center, "type": type, "final": final])
    }
}

// MARK: Gameplay actions and logic
extension GameEngine {
    /// Remove identically-colored and connected bubbles from root bubble
    /// if group of bubbles exceed certain amount
    /// - Parameter index: index of root bubble
    private func removeAdjacentSimilarColorBubbles(of index: Int, _ player: PlayerType) {
        let similarGroupIndices = getAdjacentSimilarColorBubbles(of: index)
        guard similarGroupIndices.count >= Constants.Game.numOfBubblesToPop else {
            return
        }
        for index in similarGroupIndices {
            removeStationaryObject(index, player)
        }
    }

    /// Drops unconnected bubbles from the top wall
    private func dropUnconnectedObjects(player: PlayerType) {
        let attachedObjects = findAttachedBubbles()
        for index in stationaryBubbleObjects.keys where !attachedObjects.contains(index) {
            dropStationaryObjectFromGrid(index: index, player: player)
        }
    }

    /// Drop all connected/stationary bubbles in the game
    func dropEverything() {
        for index in stationaryBubbleObjects.keys {
            dropStationaryObjectFromGrid(index: index, player: .bot)
        }
    }
}

// MARK: Powers
extension GameEngine {
    private func handlePowerBubbles(around index: Int, of type: BubbleType, _ player: PlayerType) {
        for neighborIndex in neighbor(of: index) {
            guard let bubble = stationaryBubbleObjects[neighborIndex] else {
                continue
            }
            switch bubble.type {
            case .bomb, .lightning:
                removeStationaryObject(neighborIndex, player)
            case .star:
                removeStationaryObject(neighborIndex, player)
                removeAllBubblesOfType(type, player)
            default:
                continue
            }
        }
    }

    private func removeAllBubblesOfType(_ typeToRemove: BubbleType, _ player: PlayerType) {
        for (index, bubble) in stationaryBubbleObjects where bubble.type == typeToRemove {
            removeStationaryObject(index, player)
        }
    }

    private func removeRow(_ index: Int, _ player: PlayerType) {
        let (firstInRow, lastInRow) = getFirstAndLastIndiceInRowOf(index)

        for index in firstInRow...lastInRow {
            removeStationaryObject(index, player)
        }
    }

    private func removeSurroundingBubbles(_ index: Int, _ player: PlayerType) {
        for neighborIndex in neighbor(of: index) {
            removeStationaryObject(neighborIndex, player)
        }
    }
}

// MARK: Helper game methods
extension GameEngine {
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
                guard neighborIndex >= 0, neighborIndex < maxNumOfBubblesInGame else {
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

    private func neighbor(of index: Int) -> [Int] {
        if isHexagonal {
            return neighborInHexagonal(of: index)
        } else {
            return neighborInRectangular(of: index)
        }
    }

    /// Neighbor index of a game object in a hexagonal isometric grid
    private func neighborInHexagonal(of index: Int) -> [Int] {
        var neighborCandidates: [Int]

        // even row, leftest
        if index % Constants.Game.numOfBubblesInRowSet == 0 {
            neighborCandidates = [index - numOfBubblesInOddRow,
                                  index + 1, index + numOfBubblesInEvenRow]
        }
            // even row, rightest
        else if index % Constants.Game.numOfBubblesInRowSet == numOfBubblesInOddRow {
            neighborCandidates =  [index - numOfBubblesInEvenRow,
                                   index - 1,
                                   index + numOfBubblesInOddRow]
        }
            // odd row, leftest
        else if index % Constants.Game.numOfBubblesInRowSet == Constants.Game.numOfBubblesInEvenRow {
            neighborCandidates =  [index - numOfBubblesInEvenRow,
                                   index - numOfBubblesInOddRow,
                                   index + 1,
                                   index + numOfBubblesInOddRow,
                                   index + numOfBubblesInEvenRow]
        }
            // odd row, rightest
        else if index % Constants.Game.numOfBubblesInRowSet == (Constants.Game.numOfBubblesInRowSet - 1) {
            neighborCandidates =  [index - numOfBubblesInEvenRow,
                                   index - numOfBubblesInOddRow,
                                   index - 1,
                                   index + numOfBubblesInOddRow,
                                   index + numOfBubblesInEvenRow]
        }
            // bubbles not on the extreme row edges
        else {
            neighborCandidates =  [index - numOfBubblesInEvenRow,
                                   index - numOfBubblesInOddRow,
                                   index - 1,
                                   index + 1,
                                   index + numOfBubblesInOddRow,
                                   index + numOfBubblesInEvenRow]
        }
        return  neighborCandidates.filter { $0 >= 0 && $0 < maxNumOfBubblesInGame }
    }

    /// Neighbor index of a game object in a hexagonal isometric grid
    private func neighborInRectangular(of index: Int) -> [Int] {
        var neighborCandidates: [Int]

        // leftest
        if index % numOfBubblesInEvenRow == 0 {
            neighborCandidates = [index - numOfBubblesInEvenRow,
                                  index + 1,
                                  index + numOfBubblesInEvenRow]
        }
        // rightest
        if index % numOfBubblesInEvenRow == (numOfBubblesInEvenRow - 1) {
            neighborCandidates = [index - numOfBubblesInEvenRow,
                                  index - 1,
                                  index + numOfBubblesInEvenRow]
        } else {
            neighborCandidates = [index - numOfBubblesInEvenRow,
                                  index - 1,
                                  index + 1,
                                  index + numOfBubblesInEvenRow]
        }
        return  neighborCandidates.filter { $0 >= 0 && $0 < maxNumOfBubblesInGame }
    }

    private func getFirstAndLastIndiceInRowOf(_ index: Int) -> (Int, Int) {
        let numOfBubblesInTwoRows = numOfBubblesInEvenRow + numOfBubblesInOddRow
        let multiplier = index / numOfBubblesInTwoRows
        let remainder = index % numOfBubblesInTwoRows

        let firstInRow: Int
        let lastInRow: Int

        if remainder < numOfBubblesInEvenRow {
            firstInRow = multiplier * numOfBubblesInTwoRows
            lastInRow = firstInRow + numOfBubblesInEvenRow
        } else {
            firstInRow = multiplier * numOfBubblesInTwoRows + numOfBubblesInEvenRow
            lastInRow = firstInRow + numOfBubblesInOddRow
        }
        return (firstInRow, lastInRow)
    }
}

// MARK: Collision resolution
extension GameEngine {
    /// Resolve collision of a moving object with a stationary object
    private func resolveCollisionWithStationaryObject(_ body1: RigidBody, with body2: RigidBody) {
        guard let object1 = dictionary[ObjectIdentifier(body1)],
            let object2 = dictionary[ObjectIdentifier(body2)] else {
            return
        }
        guard movingBubbleObjects.contains(object1),
            stationaryBubbleObjectsMap.keys.contains(object2) else {
            return
        }
        switch (body1.shape, body2.shape) {
        case (Shape.circle, Shape.circle):
            connectToNearestPosition(object1, to: object2)
        }
    }

    /// Resolve collision of a moving object with walls/bounds
    private func resolveMovingObjectCollisionWithWall(_ body: RigidBody, with wall: Wall) {
        guard let object = dictionary[ObjectIdentifier(body)] else {
            return
        }
        switch wall {
        case .top:
            switch body.shape {
            case Shape.circle:
                connectToNearestPositionOnTopWall(object)
            }
        case .bottom:
            // remove moving object when reached bottom of screen
            movingBubbleObjects.remove(object)
            physicsEngine.removeMovingBody(object.body)
            dictionary.removeValue(forKey: ObjectIdentifier(object.body))
        case .left, .right:
            resolveBoundCollisionBetween(body: body, wall: wall)
        }
    }

    /// Resolve collision of a dropping object with walls/bounds
    private func resolveDroppingObjectCollisionWithWall(_ body: RigidBody, with wall: Wall) {
        guard let object = dictionary[ObjectIdentifier(body)] else {
            return
        }
        switch wall {
        case .bottom:
            // remove dropping object when reached bottom of screen
            droppingBubbleObjects.remove(object)
            physicsEngine.removeDroppingBody(object.body)
            dictionary.removeValue(forKey: ObjectIdentifier(object.body))
            popCell(type: object.type, playerId: object.player)

        case .top, .left, .right:
            resolveBoundCollisionBetween(body: body, wall: wall)
        }
    }

    /// Snaps bubble to the closest empty cell when it collides with an existing bubble
    /// - Parameter object: bubble which collides and to be positioned
    private func connectToNearestPosition(_ object: BubbleObject, to toObject: BubbleObject) {
        guard let index = findNearestPositionIndex(object.body.position, toObject) else {
            return
        }
        connectObject(object, to: index)
    }

    /// Snaps bubble to the closest empty cell when it collides with top wall
    /// - Parameter object: bubble which collides and to be positioned
    private func connectToNearestPositionOnTopWall(_ object: BubbleObject) {
        guard let index = findNearestPositionIndexToWall(object.body.position) else {
            return
        }
        connectObject(object, to: index)

    }

    private func connectObject(_ object: BubbleObject, to index: Int) {
        let player = object.player
        switch object.body.shape {
        case Shape.circle(radius: let radius):
            self.insertStationaryBubble(radius: radius,
                                        type: object.type, index: index)

            let vector = object.body.position
            let position = gridPositions[index]
            let center = CGPoint(x: vector.xComponent, y: vector.yComponent)
            let final = CGPoint(x: position.xComponent, y: position.yComponent)
            self.moveCell(center, object.type, final)
            self.removeMovingObject(object)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            self.removeAdjacentSimilarColorBubbles(of: index, player)
            self.handlePowerBubbles(around: index, of: object.type, player)
            self.dropUnconnectedObjects(player: player)

            // Detect for game over
            if self.detectGameOver(index: index) {
                self.gameOver(player)
            } else if self.bubblesLeft.isEmpty {
                self.noBubblesLeft()
            }
        })
    }

    /// Find closest empty cell when bubble collides with an existing bubble
    private func findNearestPositionIndex(_ position: Vector2, _ stationaryObject: BubbleObject) -> Int? {
        var nearestIndex: Int?
        var nearestDistance = Double.greatestFiniteMagnitude

        guard let collisionIndex = stationaryBubbleObjectsMap[stationaryObject] else {
            return nil
        }

        for index in neighbor(of: collisionIndex) where !stationaryBubbleObjects.keys.contains(index) {
            let distance = position.distance(with: gridPositions[index])
            if distance < nearestDistance {
                nearestIndex = index
                nearestDistance = distance
            }
        }
        return nearestIndex
    }

    /// Find closest empty cell when bubble collides with an existing bubble
    private func findNearestPositionIndexToWall(_ position: Vector2) -> Int? {
        var nearestIndex: Int?
        var nearestDistance = Double.greatestFiniteMagnitude

        for index in 0...numOfBubblesInEvenRow where !stationaryBubbleObjects.keys.contains(index) {
            let distance = position.distance(with: gridPositions[index])
            if distance < nearestDistance {
                nearestIndex = index
                nearestDistance = distance
            }
        }
        return nearestIndex
    }

    private func detectGameOver(index: Int) -> Bool {
        if isHexagonal {
            return index > Constants.Game.maxNumOfBubblesInHex - Constants.Game.numOfBubblesInEvenRow
        } else {
            return index > Constants.Game.maxNumOfBubblesInRect - Constants.Game.numOfBubblesInEvenRow
        }
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
        guard let objectA = dictionary[ObjectIdentifier(bodyA)],
            let objectB = dictionary[(ObjectIdentifier(bodyB))] else {
                print("not found")
                return
        }
        guard objectA.player != objectB.player else {
            return
        }

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
