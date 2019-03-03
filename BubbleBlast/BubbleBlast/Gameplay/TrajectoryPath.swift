//
//  TrajectoryPath.swift
//  BubbleBlast
//
//  Created by Jie Liang Ang on 3/3/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import UIKit

class TrajectoryPath: UIView {
    private var enabled = false
    private var startPoint = CGPoint(x: 0, y: 0)
    private var endPoint = CGPoint(x: 0, y: 0)
    private var color = UIColor.black
    private var radius: CGFloat = 0

    let dashLength: CGFloat = 10
    let patternLength = 2
    let dashWidth = 3

    func setStartPoint(_ point: CGPoint) {
        self.startPoint = point
        self.setNeedsDisplay()
    }

    func setEndPoint(_ point: CGPoint) {
        self.endPoint = point
        self.setNeedsDisplay()
    }

    func setEnabled(_ enabled: Bool) {
        self.enabled = enabled
        self.setNeedsDisplay()
    }

    func setColor(_ color: UIColor) {
        self.color = color
    }

    func setRadius(_ radius: CGFloat) {
        self.radius = radius
    }

    override func draw(_ rect: CGRect) {
        guard enabled else {
            return
        }
        let path = UIBezierPath()
        path.move(to: startPoint)
        let reflectPoint = getReflectedPoint(startPoint, endPoint)
        path.addLine(to: reflectPoint)
        path.addLine(to: getExtendedEndPoint(startPoint, reflectPoint, endPoint))

        path.lineWidth = 5

        let dashPattern: [CGFloat] = [dashLength, dashLength]
        path.setLineDash(dashPattern, count: patternLength, phase: 0)
        color.setStroke()
        path.stroke(with: CGBlendMode.color, alpha: 0.5)
    }

    func getReflectedPoint(_ start: CGPoint, _ end: CGPoint) -> CGPoint {
        let reflectX: CGFloat = (endPoint.x > start.x) ? frame.size.width - radius : radius
        let reflectY = ((start.y - end.y) / (start.x - end.x)) * (reflectX - start.x) + start.y
        return CGPoint(x: reflectX, y: reflectY)
    }

    func getExtendedEndPoint(_ start: CGPoint, _ reflect: CGPoint, _ end: CGPoint) -> CGPoint {
        let extrapolatedEndX = start.x
        let extrapolatedEndY = reflect.y - abs((reflect.y - start.y))
        let totalDistance = sqrt(Double((extrapolatedEndY - reflect.y) * (extrapolatedEndY - reflect.y) +
                                (extrapolatedEndX  - reflect.x) * (extrapolatedEndX  - reflect.x)))

        let extendDistance =  frame.width / 3

        let finalX = reflect.x + extendDistance / CGFloat(totalDistance) * (extrapolatedEndX - reflect.x)
        let finalY = reflect.y + extendDistance / CGFloat(totalDistance) * (extrapolatedEndY  - reflect.y)

        return CGPoint(x: finalX, y: finalY)
    }
}
