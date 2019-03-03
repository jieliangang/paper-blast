//
//  BubbleType.swift
//  LevelDesigner
//
//  Created by Jie Liang Ang on 7/2/19.
//  Copyright © 2019 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
/**
 `BubbleType` represents all the possible types of `BubbleObject`.
 Adapted from PS3
 */
enum BubbleType: String, Codable, CaseIterable {
    case empty
    case colorRed
    case colorYellow
    case colorGreen
    case colorBlue
    case indestructible
    case lightning
    case bomb
    case star

    static func randomType() -> BubbleType {
        let index = Int(arc4random_uniform(UInt32(Constants.Game.colorTypes.count)))
        return Constants.Game.colorTypes[index]
    }

    /// Cycle color if `BubbleType` is of color
    /// - Returns: Cycled `BubbleType` if original type is color
    ///             else returns same `BubbleType`
    func next() -> BubbleType {
        switch self {
        case .colorYellow: return .colorRed
        case .colorRed: return .colorBlue
        case .colorGreen: return .colorYellow
        case .colorBlue: return .colorGreen
        default: return self
        }
    }

    func hasPower() -> Bool {
        return Constants.Game.powerTypes.contains(self)
    }

    func isColor() -> Bool {
        return Constants.Game.colorTypes.contains(self)
    }
}
