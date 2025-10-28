//
//  Colorable.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import CoreGraphics
import AppKit

enum LFStrokePosition: Int, Hashable, CaseIterable {
    case inside, center, outside
}

protocol Colorable {
    var fill: NSColor { get set }
    var stroke: NSColor { get set }
    var strokeWidth: CGFloat { get set }
    var strokePosition: LFStrokePosition { get set }
}
