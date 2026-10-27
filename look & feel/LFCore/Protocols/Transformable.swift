//
//  Transformable.swift
//  look & feel
//

import CoreGraphics

/// A layer that can be moved and rotated. Every layer type conforms.
protocol Transformable {
    var position: CGPoint { get set }
    var rotation: CGFloat { get set }

    mutating func setPosition(_ position: CGPoint)
    mutating func setRotation(_ rotation: CGFloat)
}
