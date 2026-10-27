//
//  LFPath.swift
//  look & feel
//

import Foundation
import CoreGraphics

/// A vector path layer (a filled/stroked bezier shape).
///
/// Converted from the old `LFLayer` subclass to a `Codable` value type. The
/// drawing implementation (bezier path construction, fill/stroke) lives in the
/// UI layer — see `LFLayer+Rendering` — so `LFCore` stays pure.
struct LFPath: Codable, Hashable {
    var base: LFBase

    var size: CGSize
    var reflection: [LFReflectionAxis]

    var fill: LFColor
    var stroke: LFColor
    var strokeWidth: CGFloat
    var strokePosition: LFStrokePosition

    var points: [LFBezierPoint]
    var isClosed: Bool

    init(
        id: UUID = UUID(),
        name: String,
        position: CGPoint = .zero,
        rotation: CGFloat = 0,
        size: CGSize,
        reflection: [LFReflectionAxis] = [],
        fill: LFColor,
        stroke: LFColor,
        strokeWidth: CGFloat,
        strokePosition: LFStrokePosition,
        points: [LFBezierPoint],
        isClosed: Bool
    ) {
        self.base = LFBase(id: id, name: name, position: position, rotation: rotation)
        self.size = size
        self.reflection = reflection
        self.fill = fill
        self.stroke = stroke
        self.strokeWidth = strokeWidth
        self.strokePosition = strokePosition
        self.points = points
        self.isClosed = isClosed
    }

    // MARK: - Transform helpers (mirror the old `Transformable` / `Resizable`)

    mutating func setPosition(_ position: CGPoint) {
        self.base.position = position
    }

    mutating func setRotation(_ rotation: CGFloat) {
        self.base.rotation = rotation
    }

    mutating func setSize(_ size: CGSize) {
        self.size = size
    }

    /// Toggle a reflection axis (add it if absent, remove it if present).
    mutating func reflect(_ axis: LFReflectionAxis) {
        if let index = self.reflection.firstIndex(of: axis) {
            self.reflection.remove(at: index)
        } else {
            self.reflection.append(axis)
        }
    }
}
