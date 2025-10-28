//
//  LFPath.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import Combine
import AppKit
import SwiftUI

class LFPath: LFLayer, Resizable, Traceable, Colorable {

    // MARK: Resizable conformance
    @Published var size: CGSize
    @Published var reflection: [LFReflectionAxis]

    // MARK: Traceable conformance
    @Published var points: [LFBezierPoint]
    @Published var isClosed: Bool
    
    // MARK: Colorable conformance
    @Published var fill: NSColor
    @Published var stroke: NSColor
    @Published var strokeWidth: CGFloat
    @Published var strokePosition: LFStrokePosition
    
    var path: NSBezierPath {
        return .init()
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        position: CGPoint,
        rotation: CGFloat = 0,

        size: CGSize,
        reflection: [LFReflectionAxis] = [],

        fill: NSColor,
        stroke: NSColor,
        strokeWidth: CGFloat,
        strokePosition: LFStrokePosition,
        
        points: [LFBezierPoint],
        isClosed: Bool
    ) {
        self.size = size
        self.reflection = reflection

        self.fill = fill
        self.stroke = stroke
        self.strokeWidth = strokeWidth
        self.strokePosition = strokePosition
        
        self.points = points
        self.isClosed = isClosed
        
        super.init(
            id: id,
            name: name,
            position: position,
            rotation: rotation
        )
    }

    var frame: CGRect {
        CGRect(
            origin: position,
            size: size
        )
    }

    func setSize(_ newSize: CGSize) {
        self.size = newSize
    }

    private func reflect(_ axis: LFReflectionAxis) {
        if !reflection.contains(axis) {
            self.reflection.append(axis)
        } else {
            self.reflection.removeAll { $0 == .horizontal }
        }
    }

    func reflect(_ axes: [LFReflectionAxis]) {
        for axis in axes { reflect(axis) }
    }

    override var symbol: AnyView {
        AnyView (
            Image(systemName: "rectangle.portrait")
        )
    }

    override func draw(in context: CGContext) {
        let path = NSBezierPath(rect: self.frame)
        
        if fill != .clear {
            fill.setFill()
            path.fill()
        }
        
        if strokeWidth > 0 && stroke != .clear {
            stroke.setStroke()
            path.lineWidth = strokeWidth
            path.stroke()
        }
    }
}
