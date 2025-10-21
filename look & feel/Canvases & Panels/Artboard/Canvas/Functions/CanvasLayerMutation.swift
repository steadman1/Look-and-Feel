//
//  CanvasLayerMutation.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/18/25.
//

import AppKit
import CoreGraphics

fileprivate let transformRequests: [LFCanvasTransformRequest] = LFCanvasTransformRequest.allCases

extension CanvasView {
    // MARK: layer mutation functions
    internal func relocate(
        initialFrames: [CGRect],
        canvasDelta: CGPoint
    ) {
        for index in 0..<viewModel.selectionLayers.count {
            let layer = viewModel.selectionLayers[index]
            let initialFrame: CGRect = initialFrames[index]
            layer.position.x = (initialFrame.origin.x + canvasDelta.x)
            layer.position.y = (initialFrame.origin.y + canvasDelta.y)
        }
    }

    internal func resize(
        initialFrames: [CGRect],
        canvasDelta: CGPoint,
        handle: LFSelectionHandle
    ) {
        guard let selectionFrame = getFrame(
            for: initialFrames,
            transformRequests: []
        ) else { return }

        for index in 0..<viewModel.selectionLayers.count {
            guard var resizable = viewModel.selectionLayers[index] as? (any Resizable) else { continue }

            let initialFrame: CGRect = initialFrames[index]
            let newFrame = getResizedFrame(
                from: initialFrame,
                canvasDelta: canvasDelta,
                min: CGPoint(x: selectionFrame.minX, y: selectionFrame.minY),
                max: CGPoint(x: selectionFrame.maxX, y: selectionFrame.maxY),
                for: handle
            )

            resizable.setPosition(
                CGPoint(
                    x: newFrame.origin.x,
                    y: newFrame.origin.y
                )
            )
            resizable.size = newFrame.size
        }
    }
}

