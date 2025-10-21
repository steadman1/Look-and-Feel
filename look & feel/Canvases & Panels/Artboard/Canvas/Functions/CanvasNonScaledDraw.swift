//
//  CanvasNonScaledDraw.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/18/25.
//

import AppKit
import CoreGraphics

fileprivate let transformRequests: [LFCanvasTransformRequest] = [.scale]

extension CanvasView {
    // MARK: translated, non-scaled draw functions
    // all functions must scale size by zoom
    internal func drawSelectionHandles(in context: CGContext) {
        guard let selectionFrame = getSelectionFrame(
            transformRequests: transformRequests
        ) else { return }
        let handles = getHandleFrames(for: selectionFrame)

        for (_, rect, _) in handles {
            let path = NSBezierPath(rect: rect)
            NSColor(resource: .strokeFocus).setStroke()
            path.lineWidth = 2
            path.stroke()

            NSColor(resource: .foregroundCanvas).setFill()
            path.fill()
        }
    }

    internal func drawSelectionBox(in context: CGContext) {
        if viewModel.selection.isEmpty { return }

        guard let selectionFrame = getSelectionFrame(
            transformRequests: transformRequests
        ) else { return }

        let path = NSBezierPath(rect: selectionFrame)

        NSColor(resource: .strokeFocus).setStroke()
        path.lineWidth = 2
        path.stroke()
    }

    internal func drawAxes(in context: CGContext) {
        let xAxis = CGRect(
            origin: CGPoint(
                x: -50000,
                y: 0
            ),
            size: .init(width: 100000, height: 1)
        )
        let yAxis = CGRect(
            origin: CGPoint(
                x: 0,
                y: -50000
            ),
            size: .init(width: 1, height: 100000)
        )

        let xPath = NSBezierPath(rect: xAxis)
        let yPath = NSBezierPath(rect: yAxis)

        NSColor.red.setStroke()
        xPath.lineWidth = 0.5
        xPath.stroke()

        NSColor.red.setStroke()
        yPath.lineWidth = 0.5
        yPath.stroke()
    }
}
