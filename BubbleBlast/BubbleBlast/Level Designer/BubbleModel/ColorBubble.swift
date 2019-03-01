//
//  ColorCell.swift
//  LevelDesigner
//
//  Created by Jie Liang Ang on 2/2/19.
//  Copyright © 2019 nus.cs3217.a0101010. All rights reserved.
//

/**
 `ColorBubble` represents a plain colored `GameBubble`
 */
class ColorBubble: GameBubble, Codable {
    var type: BubbleType

    private let typeArray = [BubbleType.colorBlue, BubbleType.colorGreen, BubbleType.colorRed, BubbleType.colorYellow]

    init?(type: BubbleType) {
        guard typeArray.contains(type) else {
            return nil
        }
        self.type = type
        assert(checkRep())
    }

    private func checkRep() -> Bool {
        return typeArray.contains(type)
    }
}
