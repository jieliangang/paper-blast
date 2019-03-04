//
//  CounterLabel.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 3/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import UIKit

class CounterLabel: UILabel {

    var bubblesLeft = 50

    func decrement() {
        bubblesLeft -= 1
        updateText()
    }

    func updateText() {
        self.text = "x\(Int(bubblesLeft))"
    }

}
