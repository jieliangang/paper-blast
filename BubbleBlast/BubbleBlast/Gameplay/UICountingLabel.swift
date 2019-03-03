//
//  UICountingLabel.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 3/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import UIKit

class UICountingLabel: UILabel {

    var startNumber: Float = 0
    var endNumber: Float = 0

    let countingVelocity: Float = 3.0

    var progress: TimeInterval!
    var duration: TimeInterval!
    var lastUpdate: TimeInterval!

    var timer: Timer?

    var currentCounterValue: Float {
        if progress == nil || duration == nil {
            return 0
        }
        if progress >= duration {
            return endNumber
        }
        let percentage = Float(progress / duration)
        let update = updateCounter(counterValue: percentage)
        return startNumber + (update * (endNumber - startNumber))
    }

    enum CounterAnimationType {
        case linear
        case easeIn
        case easeOut
    }

    // Linear for this game
    let counterAnimationType = CounterAnimationType.linear

    func increment(value: Float) {
        count(fromValue: currentCounterValue, toValue: endNumber + value, withDuration: 0.7)
    }

    func decrementByOne() {
        count(fromValue: currentCounterValue, toValue: endNumber - 1, withDuration: 0.1)
    }

    func count(fromValue: Float, toValue: Float, withDuration duration: TimeInterval) {
        self.startNumber = fromValue
        self.endNumber = toValue
        self.duration = duration
        self.progress = 0
        self.lastUpdate = Date.timeIntervalSinceReferenceDate

        timer?.invalidate()

        if duration == 0 {
            updateText(value: toValue)
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(UICountingLabel.updateValue),
                                     userInfo: nil, repeats: true)

    }

    func updateText (value: Float) {
        self.text = "\(Int(value))"
    }

    func updateCounter (counterValue: Float) -> Float {
        switch counterAnimationType {
        case .linear: return counterValue
        case .easeIn: return powf(counterValue, countingVelocity)
        case .easeOut: return 1.0 - powf(1.0 - counterValue, countingVelocity)
        }
    }

    @objc func updateValue() {
        let now = Date.timeIntervalSinceReferenceDate
        progress += (now - lastUpdate)
        lastUpdate = now

        if progress >= duration {
            timer?.invalidate()
            timer = nil
            progress = duration
        }
        updateText(value: currentCounterValue)
    }
}
