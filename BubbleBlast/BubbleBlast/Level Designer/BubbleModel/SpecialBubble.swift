//
//  SpecialBubble.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import Foundation
/**
 `SpecialBubble` represents an empty `GameBubble`
 */
class SpecialBubble: GameBubble, Codable {
    var type: BubbleType

    private let typeArray = [BubbleType.indestructible, BubbleType.lightning,
                             BubbleType.bomb, BubbleType.star]

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
