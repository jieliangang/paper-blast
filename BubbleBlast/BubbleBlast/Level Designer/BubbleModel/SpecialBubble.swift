//
//  SpecialBubble.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import Foundation
/**
 `SpecialBubble` represents a special power `GameBubble`
 */
class SpecialBubble: GameBubble, Codable {
    var type: BubbleType

    init?(type: BubbleType) {
        guard Constants.Game.specialTypes.contains(type) else {
            return nil
        }
        self.type = type
        assert(checkRep())
    }

    private func checkRep() -> Bool {
        return Constants.Game.specialTypes.contains(type)
    }
}
