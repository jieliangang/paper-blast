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
        let typeToGet = [BubbleType.colorBlue, BubbleType.colorRed, BubbleType.colorGreen, BubbleType.colorYellow]
        let index = Int(arc4random_uniform(UInt32(typeToGet.count)))
        return typeToGet[index]
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
        return [BubbleType.lightning, .bomb, .star].contains(self)
    }

    func isColor() -> Bool {
        return [BubbleType.colorBlue, .colorRed, .colorGreen, .colorYellow].contains(self)
    }
}
