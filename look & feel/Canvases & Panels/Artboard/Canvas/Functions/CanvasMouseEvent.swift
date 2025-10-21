//
//  CanvasMouseEvent.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/18/25.
//

import AppKit
import CoreGraphics

fileprivate let transformRequests: [LFCanvasTransformRequest] = LFCanvasTransformRequest.allCases

extension CanvasView {
    // MARK: mouse event override funcs
    // these funcs need to account for both translation and scaling of objects
    override func mouseDown(with event: NSEvent) {
        let mouseInView = self.convert(event.locationInWindow, from: nil)

        guard let selectionFrame = getSelectionFrame(
            transformRequests: transformRequests
        ) else { return }

        let handles = getHandleFrames(for: selectionFrame)

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

        if selectionFrame.contains(mouseInView) {
            NSCursor.closedHand.set()
            viewModel.mouseDragState = .relocating(
                initialMouse: mouseInView,
                initialFrames: viewModel.selectionLayers.compactMap { getFrame(of: $0) }
            )
            return
        }
    }

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

    override func magnify(with event: NSEvent) {
        let mouseInView = self.convert(event.locationInWindow, from: nil)

        let canvasLocationUnderMouse = getCanvasLocationUnderMouse(for: mouseInView)

        let oldZoom = viewModel.zoom
        let newZoom = max(oldZoom + event.magnification, 0.05)
        viewModel.zoom = newZoom

        viewModel.panOffset = CGPoint(
            x: mouseInView.x - (canvasLocationUnderMouse.x * newZoom),
            y: mouseInView.y - (canvasLocationUnderMouse.y * newZoom)
        )
    }

    override func scrollWheel(with event: NSEvent) {
        viewModel.panOffset.x += event.scrollingDeltaX
        viewModel.panOffset.y += event.scrollingDeltaY
    }

    override func mouseMoved(with event: NSEvent) {
        let mouseInView = self.convert(event.locationInWindow, from: nil)

        guard let selectionFrame = getSelectionFrame(
            transformRequests: transformRequests
        ) else { return }
        let handles = getHandleFrames(for: selectionFrame)

        // TODO: switch to quad tree for efficient collision detection
        for layer in viewModel.layers {
            guard let resizable = layer as? (any Resizable) else { continue }

            let canvasFrame = getCanvasFrame(
                for: CGRect(origin: resizable.position, size: resizable.size),
                with: transformRequests
            )
            if canvasFrame.contains(mouseInView) {
                if viewModel.selection.contains(resizable.id) {
                    NSCursor.openHand.set()
                } else {
                    NSCursor.pointingHand.set()
                }
                return
            }
        }

        for (handle, _, rect) in handles {
            if rect.contains(mouseInView) {
                handle.cursor.set()

                return
            }
        }

        NSCursor.arrow.set()
    }

    override func mouseDragged(with event: NSEvent) {
        let mouseInView = self.convert(event.locationInWindow, from: nil)

        switch viewModel.mouseDragState {
        case .inactive:
            return
        case .resizing(let handle, let initialMouse, let initialFrames):
            let mouseDelta = getMouseDelta(from: initialMouse, with: mouseInView)
            let canvasDelta = getCanvasDelta(from: mouseDelta)

            resize(
                initialFrames: initialFrames,
                canvasDelta: canvasDelta,
                handle: handle
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
}
