//
//  Resizable.swift
//  look & feel
//

import CoreGraphics

/// A layer that exposes width/height and can be scaled or reflected.
protocol Resizable {
    var size: CGSize { get set }
    var frame: CGRect { get }
    var reflection: [LFReflectionAxis] { get set }

    mutating func setSize(_ size: CGSize)
    mutating func reflect(_ axis: LFReflectionAxis)
}
