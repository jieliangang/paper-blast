//
//  Player.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 1/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import Foundation

/**
 Type of Player
 */
enum PlayerType {
    case one, two, bot, single
    
    func otherPlayer() -> PlayerType {
        switch self {
        case .one: return .two
        case .two: return .one
        default: return self
        }
    }
}
