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
        selectionFrame: CGRect,
        canvasDelta: CGPoint,
        for handle: LFSelectionHandle
    ) {
        for index in 0..<viewModel.selectionLayers.count {
            guard let resizable = viewModel.selectionLayers[index] as? (any Resizable) else { continue }
            let initialFrame: CGRect = initialFrames[index]

            let newFrame = getResizedFrame(
                initialFrame: initialFrame,
                selectionFrame: selectionFrame,
                canvasDelta: canvasDelta,
                for: handle
            )

            resizable.setPosition(newFrame.origin)
            resizable.setSize(newFrame.size)
        }
    }
}

