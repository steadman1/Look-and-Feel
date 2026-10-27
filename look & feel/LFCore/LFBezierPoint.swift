//
//  LFBezierPoint.swift
//  look & feel
//

import Foundation
import CoreGraphics

/// A single control point of a bezier trace.
///
/// Converted from the old `ObservableObject` class to a `Codable` value type so
/// traces can be snapshotted, diffed, and serialized. Mutating a point now means
/// replacing it in its parent path's `points` array (see `LFLayer`).
struct LFBezierPoint: Codable, Hashable, Identifiable {
    var id: UUID
    var cornerStyle: LFCornerStyle
    var anchor: CGPoint
    var handle1: CGPoint
    var handle2: CGPoint

    /// How the two handles relate to each other around this anchor.
    enum LFCornerStyle: Int, Codable, Hashable, CaseIterable {
        case corner      // sharp corner; handles independent
        case mirrored    // smooth; handles are collinear & equidistant
        case asymmetric  // smooth; handles collinear but different lengths
    }

    init(
        id: UUID = UUID(),
        cornerStyle: LFCornerStyle,
        anchor: CGPoint,
        handle1: CGPoint,
        handle2: CGPoint
    ) {
        self.id = id
        self.cornerStyle = cornerStyle
        self.anchor = anchor
        self.handle1 = handle1
        self.handle2 = handle2
    }

    /// A point with no handles (a plain corner) at `point`.
    init(at point: CGPoint) {
        self.init(cornerStyle: .corner, anchor: point, handle1: point, handle2: point)
    }
}
