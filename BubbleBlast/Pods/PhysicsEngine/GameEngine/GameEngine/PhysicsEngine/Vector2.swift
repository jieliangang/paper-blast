//
//  Vector.swift
//  GameEngine
//
//  Created by Jie Liang Ang on 13/2/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import Foundation
import UIKit

/**
 `Vector2` represents a 2-dimensional vector.
 */
public struct Vector2: Equatable, Hashable {
    public var xComponent: Double
    public var yComponent: Double

    public init(xComponent: Double, yComponent: Double) {
        self.xComponent = xComponent
        self.yComponent = yComponent
    }

    public init(xCGComponent: CGFloat, yCGComponent: CGFloat) {
        self.xComponent = Double(xCGComponent)
        self.yComponent = Double(yCGComponent)
    }

    public init(point: CGPoint) {
        self.xComponent = Double(point.x)
        self.yComponent = Double(point.y)
    }

    /// Converts `Vector2` to `CGPoint`
    /// - Returns: `CGPoint` representation of `Vector2`
    public func toCGPoint() -> CGPoint {
        return CGPoint(x: self.xComponent, y: self.yComponent)
    }

    /// Calculates distance to vector
    /// - Parameters: The vector to calculate distance from
    /// - Returns: The distance to vector
    public func distance(with vector: Vector2) -> Double {
        return sqrt(pow(self.xComponent - vector.xComponent, 2) + pow(self.yComponent - vector.yComponent, 2))
    }

    /// Calculates magnitude of vector
    /// - Returns: Magnitude of vector
    public func magnitude() -> Double {
        return sqrt(xComponent * xComponent + yComponent * yComponent)
    }

    /// Calculates dot product of two vectors
    /// - Returns: Dot product with vector
    public func dot(_ vector: Vector2) -> Double {
        return self.xComponent * vector.xComponent + self.yComponent * vector.yComponent
    }

    public static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(xComponent: lhs.xComponent + rhs.xComponent,
                       yComponent: lhs.yComponent + rhs.yComponent)
    }

    public static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(xComponent: lhs.xComponent - rhs.xComponent,
                       yComponent: lhs.yComponent - rhs.yComponent)
    }

    public static func * (lhs: Vector2, rhs: Double) -> Vector2 {
        return Vector2(xComponent: lhs.xComponent * rhs,
                       yComponent: lhs.yComponent * rhs)
    }

    public static prefix func - (vector: Vector2) -> Vector2 {
        return Vector2(xComponent: -vector.xComponent, yComponent: -vector.yComponent)
    }

    public static func += (lhs: inout Vector2, rhs: Vector2) {
        lhs = Vector2(xComponent: lhs.xComponent + rhs.xComponent,
                      yComponent: lhs.yComponent + rhs.yComponent)
    }

    public static func -= (lhs: inout Vector2, rhs: Vector2) {
        lhs = Vector2(xComponent: lhs.xComponent - rhs.xComponent,
                      yComponent: lhs.yComponent - rhs.yComponent)
    }

    // Null vector
    public static func null() -> Vector2 {
        return Vector2(xComponent: 0, yComponent: 0)
    }
}
