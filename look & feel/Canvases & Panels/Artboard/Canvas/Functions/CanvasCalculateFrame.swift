//
//  CanvasCalculateFrame.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/18/25.
//

import AppKit
import CoreGraphics

extension CanvasView {
    // MARK: bounding box/frame calculation functions
    internal func getCanvasFrame(
        for canvasFrame: CGRect,
        with transformRequests: [LFCanvasTransformRequest]
    ) -> CGRect {
        let (translation, scale, _) = handleTransformRequests(for: transformRequests)
        return canvasFrame
            .applying(
                CGAffineTransform(
                    translationX: translation.x,
                    y: translation.y
                )
            )
            .applying(
                CGAffineTransform(
                    scaleX: scale,
                    y: scale
                )
            )
    }

    internal func getHandleFrames(for frame: CGRect) -> [(handle: LFSelectionHandle, rectView: CGRect, rectBound: CGRect)] {
        let handleVisibleSize = CGSize(width: 4, height: 4)
        let handleBoundingBoxSize = CGSize(width: 16, height: 16)
        var handles: [(LFSelectionHandle, CGRect, CGRect)] = []

        let handleTypes: [[LFSelectionHandle?]] = [
            [ .topLeft, .top, .topRight],
            [ .left, nil, .right ],
            [ .bottomLeft, .bottom, .bottomRight]
        ]

        for (y, row) in handleTypes.enumerated() {
            for (x, handleType) in row.enumerated() {
                guard let handle = handleType else { continue }

                let positionVisible = CGPoint(
                    x: frame.origin.x + (frame.size.width * CGFloat(x) / 2) - (handleVisibleSize.width / 2),
                    y: frame.origin.y + (frame.size.height * CGFloat(y) / 2) - (handleVisibleSize.height / 2)
                )

                let positionBoundingBox = CGPoint(
                    x: frame.origin.x + (frame.size.width * CGFloat(x) / 2) - (handleBoundingBoxSize.width / 2),
                    y: frame.origin.y + (frame.size.height * CGFloat(y) / 2) - (handleBoundingBoxSize.height / 2)
                )

                handles.append(
                    (
                        handle,
                        CGRect(origin: positionVisible, size: handleVisibleSize),
                        CGRect(origin: positionBoundingBox, size: handleBoundingBoxSize)
                    )
                )
            }
        }
        return handles
    }

    internal func getFrame(of: LFLayer) -> CGRect? {
        guard let resizeable = of as? (any Resizable) else { return nil }

        let minPoint: CGPoint = of.position
        let maxPoint: CGPoint = CGPoint(
            x: of.position.x + resizeable.size.width,
            y: of.position.y + resizeable.size.height
        )

        let position = minPoint
        let size = CGSize(
            width: maxPoint.x - minPoint.x,
            height: maxPoint.y - minPoint.y
        )

        return NSRect(origin: position, size: size)
    }

    internal func getFrame(
        for frames: [CGRect],
        transformRequests: [LFCanvasTransformRequest]
    ) -> CGRect? {
        let (translation, zoom, _) = handleTransformRequests(for: transformRequests)

        var maxPoint: CGPoint? = nil
        var minPoint: CGPoint? = nil

        for frame in frames {
            guard let min = minPoint, let max = maxPoint else {
                minPoint = frame.origin
                maxPoint = CGPoint(
                    x: frame.origin.x + frame.size.width,
                    y: frame.origin.y + frame.size.height
                )
                continue
            }

            minPoint!.x = frame.origin.x < min.x ? frame.origin.x : min.x
            minPoint!.y = frame.origin.y < min.y ? frame.origin.y : min.y

            var point = frame.origin.x + frame.size.width
            maxPoint!.x = point > max.x ? point : max.x

            point = frame.origin.y + frame.size.height
            maxPoint!.y = point > max.y ? point : max.y
        }

        guard let maxPoint, let minPoint else { return nil }

        let position = CGPoint(
            x: translation.x + minPoint.x * zoom,
            y: translation.y + minPoint.y * zoom
        )
        let size = CGSize(
            width: (maxPoint.x - minPoint.x) * zoom,
            height: (maxPoint.y - minPoint.y) * zoom
        )

        return CGRect(origin: position, size: size)
    }

    internal func getSelectionFrame(
        transformRequests: [LFCanvasTransformRequest]
    ) -> CGRect? {
        let frame = getFrame(
            for: viewModel.selectionLayers.compactMap { selected in
                guard let resizeable = selected as? (any Resizable) else { return nil }
                return CGRect(origin: selected.position, size: resizeable.size)
            },
            transformRequests: transformRequests
        )
        return frame
    }

    internal func getResizedFrame(
        from initialFrame: CGRect,
        canvasDelta: CGPoint,
        min minPoint: CGPoint,
        max maxPoint: CGPoint,
        for handle: LFSelectionHandle
    ) -> CGRect {
        var deltaWidth: CGFloat = 0
        var deltaHeight: CGFloat = 0

        switch handle {
        case .left, .topLeft, .bottomLeft:
            deltaWidth = -canvasDelta.x
        case .right, .topRight, .bottomRight:
            deltaWidth = canvasDelta.x
        default:
            break
        }

        switch handle {
        case .top, .topLeft, .topRight:
            deltaHeight = -canvasDelta.y
        case .bottom, .bottomLeft, .bottomRight:
            deltaHeight = canvasDelta.y
        default:
            break
        }

        let anchor = CGPoint(
            x: initialFrame.minX - minPoint.x,
            y: initialFrame.minY - minPoint.y
        )

        let selectionDelta = CGSize(
            width: ((maxPoint.x - minPoint.x) + deltaWidth) / (maxPoint.x - minPoint.x) - 1,
            height: ((maxPoint.y - minPoint.y) + deltaHeight) / (maxPoint.y - minPoint.y) - 1
        )

        let newSize = CGSize(
            width: initialFrame.width + initialFrame.width * selectionDelta.width,
            height: initialFrame.height + initialFrame.height * selectionDelta.height
        )
        let newOrigin = CGPoint(
            x: initialFrame.origin.x + anchor.x * selectionDelta.width,
            y: initialFrame.origin.y + anchor.y * selectionDelta.height
        )

        return CGRect(origin: newOrigin, size: newSize)
    }
}
