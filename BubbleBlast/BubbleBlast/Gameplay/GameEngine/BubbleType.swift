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
    case colorRed
    case colorYellow
    case colorGreen
    case colorBlue

    static func randomType() -> BubbleType {
        let typeToGet = [BubbleType.colorBlue, BubbleType.colorRed, BubbleType.colorGreen, BubbleType.colorYellow]
        let index = Int(arc4random_uniform(UInt32(typeToGet.count)))
        return typeToGet[index]
    }
}
