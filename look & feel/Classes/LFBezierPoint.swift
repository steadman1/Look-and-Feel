//
//  LFShape.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import CoreGraphics
import Foundation
import Combine

// thanks gemini
class LFBezierPoint: ObservableObject, Identifiable {
    final let id: UUID = UUID()
    
    @Published var cornerStyle: LFCornerStyle
    @Published var anchor: CGPoint
    
    /// The control point that dictates the curve *entering* the anchor.
    /// Note: This is stored as an absolute coordinate, not a relative offset.
    @Published var handle1: CGPoint
    
    /// The control point that dictates the curve *leaving* the anchor.
    /// Note: This is stored as an absolute coordinate, not a relative offset.
    @Published var handle2: CGPoint
    
    init(cornerStyle: LFCornerStyle, anchor: CGPoint, handle1: CGPoint, handle2: CGPoint) {
        self.cornerStyle = cornerStyle
        self.anchor = anchor
        self.handle1 = handle1
        self.handle2 = handle2
    }
    
    convenience init(at point: CGPoint) {
        self.init(cornerStyle: .corner, anchor: point, handle1: point, handle2: point)
    }

    enum LFCornerStyle {
        /// The handles are independent, creating a sharp corner.
        case corner
        /// The handles are collinear and equidistant from the anchor, creating a symmetrical curve.
        case mirrored
        /// The handles are collinear but can have different distances from the anchor.
        case asymmetric
    }
}
