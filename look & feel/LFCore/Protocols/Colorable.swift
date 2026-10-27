//
//  Colorable.swift
//  look & feel
//

import CoreGraphics

/// Where a stroke is painted relative to a path's centerline.
enum LFStrokePosition: Int, Codable, Hashable, CaseIterable {
    case inside, center, outside
}

/// A layer that can be filled and stroked.
///
/// Uses the pure `LFColor` value type (not `NSColor`) so it stays in `LFCore`.
protocol Colorable {
    var fill: LFColor { get set }
    var stroke: LFColor { get set }
    var strokeWidth: CGFloat { get set }
    var strokePosition: LFStrokePosition { get set }
}
