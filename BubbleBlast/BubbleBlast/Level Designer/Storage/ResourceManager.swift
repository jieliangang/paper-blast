//
//  ResourceManager.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 1/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import Foundation
import UIKit

class ResourceManager {
    static func imageName(of type: BubbleType) -> String {
        let name: String
        switch type {
        case .colorBlue: name = "bubble-blue.png"
        case .colorYellow: name = "bubble-orange.png"
        case .colorRed: name = "bubble-red.png"
        case .colorGreen: name = "bubble-green.png"
        case .indestructible: name = "bubble-indestructible.png"
        case .bomb: name = "bubble-bomb.png"
        case .lightning: name = "bubble-lightning.png"
        case .star: name = "bubble-star.png"
        default: name = "bubble-transluent_black.png"
        }
        return name
    }

    static func imageView(of type: BubbleType) -> UIImage? {
        return UIImage(named: imageName(of: type))
    }

    static func color(of type: BubbleType) -> UIColor {
        switch type {
        case .colorRed: return .red
        case .colorBlue: return .blue
        case .colorGreen: return .green
        case .colorYellow: return .yellow
        default: return .black
        }
    }
}
