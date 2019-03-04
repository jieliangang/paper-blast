//
//  GameBubbleSet.swift
//  LevelDesigner
//
//  Created by Jie Liang Ang on 2/2/19.
//  Copyright © 2019 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

/**
 `GameBubbleSet` contains all the `GameBubbles` in order from left to right, then top
 to bottom.
 */
class GameBubbleSet: Codable {
    private var bubbles = [GameBubble]()
    private(set) var isHexagonal = true

    /// Creates a hexagonal `GameBubbleSet` with all bubbles set to `EmptyBubble`
    /// - Parameter numberOfRows: the number of rows the bubble grid contains
    init(numberOfRows: Int) {
        guard numberOfRows >= 0 else {
            return
        }
        let numberOfBubbles = Constants.LevelDesigner.totalNumOfBubblesInHex
        for _ in 0..<numberOfBubbles {
            bubbles.append(EmptyBubble())
        }
    }

    /// Returns the `GameBubble` at index given
    /// - Parameter index: position of bubble
    /// - Returns: the `GameBubble` if present
    func bubble(at index: Int) -> GameBubble? {
        guard index < numberOfBubbles else {
            return nil
        }
        return bubbles[index]
    }

   /// Removes the `GameBubble` at index given
    /// - Parameter index: position of bubble
    func removeBubble(at index: Int) {
        guard index < numberOfBubbles else {
            return
        }
        bubbles[index] = EmptyBubble()
    }

    /// Updates the type of `GameBubble` at index given
    /// - Parameters:
    ///     - index: position of bubble
    ///     - type: new `BubbleType`
    func updateBubble(at index: Int, to type: BubbleType) {
        guard index < numberOfBubbles else {
            return
        }
        bubbles[index] = bubbleOfType(type)
    }

    /// Cycle the type of `GameBubble` at index
    /// - Parameters:
    ///     - index: position of bubble
    func cycleBubble(at index: Int) {
        guard index < numberOfBubbles else {
            return
        }
        let type = bubbles[index].type
        updateBubble(at: index, to: type.next())
    }

    /// Clear all bubbles to `EmptyBubble`
    func reset() {
        for index in bubbles.indices {
            removeBubble(at: index)
        }
    }

    /// Size of `GameBubbleSet`
    var numberOfBubbles: Int {
        return bubbles.count
    }

    /// Return array of bubble types
    var bubbleTypes: [BubbleType] {
        return bubbles.map { $0.type }
    }

    /// Update model when alternating between layouts
    func updateGridLayout(toHex: Bool) {
        guard isHexagonal != toHex else {
            return
        }
        isHexagonal = toHex
        isHexagonal ? removePadding() : addPadding()
    }

    /// Add padding bubbles
    private func addPadding() {
        for index in stride(from: Constants.Game.numOfBubblesInRowSet,
                            through: Constants.LevelDesigner.totalNumOfBubblesInHex,
                            by: Constants.Game.numOfBubblesInRowSet).reversed() {
                                bubbles.insert(EmptyBubble(), at: index)
        }
    }

    /// Remove padding bubbles
    private func removePadding() {
        for index in stride(from: Constants.Game.numOfBubblesInRowSet,
                            through: Constants.LevelDesigner.totalNumOfBubblesInRect,
                            by: Constants.Game.numOfBubblesInRowSet + 1).reversed() {
                                bubbles.remove(at: index)
        }
    }

    /// Returns bubble types left on the grid
    var typesLeft: Set<BubbleType> {
        return Set(bubbles.map { $0.type }
                          .filter { $0.isColor()})
    }

    // Return corresponding `GameBubble` subclass of `BubbleType`
    private func bubbleOfType(_ type: BubbleType) -> GameBubble {
        switch type {
        case .empty:
            return EmptyBubble()
        case .colorRed, .colorBlue, .colorGreen, .colorYellow:
            guard let bubble = ColorBubble(type: type) else {
                return EmptyBubble()
            }
            return bubble
        default:
            guard let bubble = SpecialBubble(type: type) else {
                return EmptyBubble()
            }
            return bubble
        }
    }

    // MARK: Encodable
    enum CodingKeys: String, CodingKey {
        case bubbles
        case gridType
    }

    func encode(to encoder: Encoder) throws {
        let codableBubbleSet = bubbles.map { $0.type }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(codableBubbleSet, forKey: .bubbles)
        try container.encode(isHexagonal, forKey: .gridType)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let codableBubbles = try values.decode([BubbleType].self, forKey: .bubbles)
        let newIsHex = try values.decode(Bool.self, forKey: .gridType)
        isHexagonal = newIsHex
        bubbles = codableBubbles.map { bubbleOfType($0) }
    }
}
