//
//  ViewController.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 2/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import UIKit
import AVFoundation

class StartViewController: UIViewController {

    var audioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        let bgm = NSURL(fileURLWithPath: Bundle.main.path(forResource: "bgm", ofType: "mp3")!)
        do {
           audioPlayer = try AVAudioPlayer(contentsOf: bgm as URL)
        } catch {
            print("error while loading bgm")
        }
        audioPlayer.prepareToPlay()
        audioPlayer.numberOfLoops = -1
        audioPlayer.volume = 0.6
        audioPlayer.play()
    }
}
