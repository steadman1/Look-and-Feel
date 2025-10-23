//
//  CanvasDraw.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/18/25.
//

import AppKit
import CoreGraphics

extension CanvasView {
    // MARK: translated, scaled draw functions
    // all functions can ignore scaling and translating
    // since context alr accounts for both
    internal func drawLFLayers(in context: CGContext) {
        context.saveGState()

        context.translateBy(x: viewModel.panOffset.x, y: viewModel.panOffset.y)
        context.scaleBy(x: viewModel.zoom, y: viewModel.zoom)

        for layer in viewModel.layers {
            layer.draw(in: context)
        }

        context.restoreGState()
    }
}
