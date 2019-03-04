//
//  ResourceManager.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 1/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

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
        case .colorRed: return UIColor(red: 241/255, green: 82/255, blue: 117/255, alpha: 1)
        case .colorBlue: return UIColor(red: 104/255, green: 184/255, blue: 245/255, alpha: 1)
        case .colorGreen: return UIColor(red: 139/255, green: 234/255, blue: 198/255, alpha: 1)
        case .colorYellow: return UIColor(red: 245/255, green: 178/255, blue: 84/255, alpha: 1)
        case .bomb: return UIColor(red: 213/255, green: 102/255, blue: 103/255, alpha: 1)
        case .lightning: return UIColor(red: 248/255, green: 202/255, blue: 75/255, alpha: 1)
        case .star: return UIColor(red: 82/255, green: 60/255, blue: 228/255, alpha: 1)
        case .indestructible: return UIColor(red: 137/255, green: 145/255, blue: 156/255, alpha: 1)
        default: return .black
        }
    }

    static func getAudioPlayer(_ name: String) -> AVAudioPlayer {
        var audioPlayer = AVAudioPlayer()
        let sound = NSURL(fileURLWithPath: Bundle.main.path(forResource: name, ofType: "wav")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: sound as URL)
        } catch {
            print("fail to load player!")
        }
        audioPlayer.prepareToPlay()
        //audioPlayer.numberOfLoops = 1
        return audioPlayer
    }

    static func transition() {
        var audioPlayer = AVAudioPlayer()
        let sound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "page-flip", ofType: "wav")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: sound as URL)
        } catch {
            print("failed to load player!")
        }
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
}
