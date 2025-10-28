//
//  CanvasMouseEvent.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/18/25.
//

import AppKit
import CoreGraphics

fileprivate let transformRequests: [LFCanvasTransformRequest] = LFCanvasTransformRequest.allCases

// MARK: mouse event override funcs
// these funcs need to account for both translation and scaling of objects
extension CanvasView {

    // MARK: mouse dragged
    override func mouseDragged(with event: NSEvent) {
        let mouseInView = self.convert(event.locationInWindow, from: nil)

        switch viewModel.mouseDragState {
        case .inactive:
            return
        case .resizing(let handle, let initialMouse, let initialFrames):
            let mouseDelta = getMouseDelta(from: initialMouse, with: mouseInView)
            let canvasDelta = getCanvasDelta(from: mouseDelta)

            // 1. using getFrame(for: ...) for consistency--not using
            // getSelectionFrame(...) as it uses updated origin and size
            // while mouseDelta/canvasDelta must use initial frame values
            // 2. no transform requests since all values bake in
            // transform and scale accordingly (a little confusing
            // but it works lol)
            guard let selectionFrame = getFrame(
                for: initialFrames,
                transformRequests: []
            ) else { return }

            resize(
                initialFrames: initialFrames,
                selectionFrame: selectionFrame,
                canvasDelta: canvasDelta,
                for: handle
            )
        case .relocating(let initialMouse, let initialFrames):
            let mouseDelta = getMouseDelta(from: initialMouse, with: mouseInView)
            let canvasDelta = getCanvasDelta(from: mouseDelta)

            relocate(
                initialFrames: initialFrames,
                canvasDelta: canvasDelta
            )
        }
    }

    // MARK: mouse down
    override func mouseDown(with event: NSEvent) {
        let mouseInView = self.convert(event.locationInWindow, from: nil)
        let canvasLocationUnderMouse = getCanvasLocationUnderMouse(for: mouseInView)

        // if mouse intersects any frames not in selection, make it selected
        // must preceed dragState events due to addSelection() race condition
        let intersection = viewModel.intersect(at: canvasLocationUnderMouse)
        if let intersection {
            if event.modifierFlags.contains(.shift) {
                viewModel.toggleSelection(intersection.id)
            } else {
                viewModel.singleSelect(intersection.id)
            }
        }

        if let selectionFrame = getSelectionFrame(transformRequests: transformRequests) {
            let handles = getHandleFrames(for: selectionFrame)

            // if mouse intersects any handle rect bounding boxes, set drag state
            for (handle, _, rect) in handles {
                if rect.contains(mouseInView) {
                    viewModel.mouseDragState = .resizing(
                        handle: handle,
                        initialMouse: mouseInView,
                        initialFrames: viewModel.selectionLayers.compactMap { getFrame(of: $0) }
                    )
                    return
                }
            }

            // if mouse intersects selectionFrame,
            if selectionFrame.contains(mouseInView) {
                NSCursor.closedHand.set()
                viewModel.mouseDragState = .relocating(
                    initialMouse: mouseInView,
                    initialFrames: viewModel.selectionLayers.compactMap { getFrame(of: $0) }
                )
                return
            }
        }

        // if mouse doesnt intersect any frames, set mouse arrow and clear selection
        if intersection == nil {
            NSCursor.arrow.set()
            viewModel.mouseDragState = .inactive
            viewModel.clearSelection()
            return
        }
    }

    // MARK: mouse up
    override func mouseUp(with event: NSEvent) {
        viewModel.mouseDragState = .inactive

        guard let selectionFrame = getSelectionFrame(
            transformRequests: transformRequests
        ) else { return }
        let mouseInView = self.convert(event.locationInWindow, from: nil)

        if selectionFrame.contains(mouseInView) {
            NSCursor.openHand.set()
            viewModel.mouseDragState = .relocating(
                initialMouse: mouseInView,
                initialFrames: viewModel.selectionLayers.compactMap { getFrame(of: $0) }
            )
            return
        } else {
            NSCursor.arrow.set()
        }
    }

    // MARK: magnify
    override func magnify(with event: NSEvent) {
        let mouseInView = self.convert(event.locationInWindow, from: nil)

        let canvasLocationUnderMouse = getCanvasLocationUnderMouse(for: mouseInView)

        var zoom = viewModel.zoom
        if event.magnification.sign == .minus && zoom > 1 {
            zoom = pow(viewModel.zoom + event.magnification, 0.99)
        } else {
            zoom = pow(viewModel.zoom + event.magnification, 1.009)
        }

        let clampedZoom = min(max(zoom, 0.05), 100)
        viewModel.zoom = clampedZoom

        viewModel.panOffset = CGPoint(
            x: mouseInView.x - (canvasLocationUnderMouse.x * clampedZoom),
            y: mouseInView.y - (canvasLocationUnderMouse.y * clampedZoom)
        )
    }

    // MARK: scroll wheel
    override func scrollWheel(with event: NSEvent) {
        viewModel.panOffset.x += event.scrollingDeltaX
        viewModel.panOffset.y += event.scrollingDeltaY
    }

    // MARK: mouse moved
    override func mouseMoved(with event: NSEvent) {
        let mouseInView = self.convert(event.locationInWindow, from: nil)
        let canvasLocationUnderMouse = getCanvasLocationUnderMouse(for: mouseInView)

        let intersection = viewModel.intersect(
            at: canvasLocationUnderMouse
        )
        if let intersection {
            if viewModel.selection.contains(intersection.id)  {
                NSCursor.openHand.set()
            } else {
                NSCursor.pointingHand.set()
            }
        }

        if let selectionFrame = getSelectionFrame(transformRequests: transformRequests) {
            let handles = getHandleFrames(for: selectionFrame)

            // check for handle intersection first, so
            // the handle will display over the rect
            for (handle, _, rect) in handles {
                if rect.contains(mouseInView) {
                    handle.cursor.set()
                    return
                }
            }
        }


        if intersection == nil { NSCursor.arrow.set() }
    }
}
