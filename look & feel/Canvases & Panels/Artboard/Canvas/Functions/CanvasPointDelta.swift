//
//  CanvasPointDelta.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/18/25.
//

import AppKit
import CoreGraphics

extension CanvasView {
    // MARK: point delta calculation functions
    internal func getMouseDelta(
        from initialMouse: CGPoint,
        with mouseInView: CGPoint
    ) -> CGPoint {
        return CGPoint(
            x: mouseInView.x - initialMouse.x,
            y: mouseInView.y - initialMouse.y
        )
    }

    internal func getCanvasDelta(
        from mouseDelta: CGPoint
    ) -> CGPoint {
        return CGPoint(
            x: mouseDelta.x / viewModel.zoom,
            y: mouseDelta.y / viewModel.zoom
        )
    }

    internal func getCanvasLocationUnderMouse(for mouseInView: CGPoint) -> CGPoint {
        return CGPoint(
            x: (mouseInView.x - viewModel.panOffset.x) / viewModel.zoom,
            y: (mouseInView.y - viewModel.panOffset.y) / viewModel.zoom
        )
    }
}
