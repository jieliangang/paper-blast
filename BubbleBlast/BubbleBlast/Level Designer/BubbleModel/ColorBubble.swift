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

    init?(type: BubbleType) {
        guard [.colorBlue, .colorGreen, .colorRed, .colorYellow].contains(type) else {
            return nil
        }
        self.type = type
        assert(checkRep())
    }

    private func checkRep() -> Bool {
        return [.colorBlue, .colorGreen, .colorRed, .colorYellow].contains(type)
    }
}
