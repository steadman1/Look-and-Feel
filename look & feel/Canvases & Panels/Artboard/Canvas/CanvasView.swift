//
//  CanvasView.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import AppKit
import SwiftUI

class CanvasView: NSView {
    
    var viewModel: ArtboardViewModel? {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTrackingArea()
    }
    
    func setupTrackingArea() {
        let options: NSTrackingArea.Options = [.inVisibleRect, .activeAlways, .mouseMoved]
        let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }
    
    override func mouseDown(with event: NSEvent) {
        guard let viewModel,
              let resizable = viewModel.firstSelectionBinding((any Resizable).self)?.wrappedValue else { return }
        
        let mouseInView = self.convert(event.locationInWindow, from: nil)
        
        let layerFrame = CGRect(origin: resizable.position, size: resizable.size)
        let screenFrame = getScreenFrame(for: layerFrame)
        let handles = getHandleRects(for: screenFrame)
        
        for (handle, _, rect) in handles {
            if rect.contains(mouseInView) {
                viewModel.mouseDragState = .resizing(handle: handle, initialMouse: mouseInView, initialFrame: layerFrame)
                
                return
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let viewModel else { return }
        viewModel.mouseDragState = .inactive
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) }
        setupTrackingArea()
    }
    
    override func mouseMoved(with event: NSEvent) {
        guard let viewModel,
                let resizable = viewModel.firstSelectionBinding((any Resizable).self)?.wrappedValue else {
            NSCursor.arrow.set()
            return
        }
        
        let mouseInView = self.convert(event.locationInWindow, from: nil)
        let screenFrame = getScreenFrame(for: CGRect(origin: resizable.position, size: resizable.size))
        let handles = getHandleRects(for: screenFrame)
        
        for (handle, _, rect) in handles {
            if rect.contains(mouseInView) {
                handle.cursor.set()
                
                return
            }
        }
        
        if screenFrame.contains(mouseInView) {
            if viewModel.selection.contains(resizable.id) {
                NSCursor.openHand.set()
            } else {
                NSCursor.pointingHand.set()
            }
            return
        }
        
        NSCursor.arrow.set()
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let viewModel else { return }
        
        let mouseInView = self.convert(event.locationInWindow, from: nil)
        
        switch viewModel.mouseDragState {
        case .inactive:
            return
        case .resizing(let handle, let initialMouse, let initialFrame):
            let screenDelta = CGPoint(
                x: mouseInView.x - initialMouse.x,
                y: mouseInView.y - initialMouse.y
            )
            let canvasDelta = CGPoint(
                x: screenDelta.x / viewModel.zoom,
                y: screenDelta.y / viewModel.zoom
            )
            resize(
                initialFrame: initialFrame,
                canvasDelta: canvasDelta,
                handle: handle
            )
        }
    }
    
    private func resize(
        initialFrame: CGRect,
        canvasDelta: CGPoint,
        handle: LFSelectionHandle
    ) {
        guard let viewModel else { return }
        
        let newFrame = calculateNewFrame(
            from: initialFrame,
            with: canvasDelta,
            for: handle
        )
        
        for layer in viewModel.selectionLayers {
            guard var resizable = layer as? (any Resizable) else { continue }
            layer.position = newFrame.origin
            resizable.size = newFrame.size
        }
    }
    
    private func calculateNewFrame(
        from initialFrame: CGRect,
        with canvasDelta: CGPoint,
        for handle: LFSelectionHandle
    ) -> CGRect {
        var newOrigin = initialFrame.origin
        var newSize = initialFrame.size
        
        // horizontal adjustments
        switch handle {
        case .left, .topLeft, .bottomLeft:
            newOrigin.x += canvasDelta.x
            newSize.width -= canvasDelta.x
        case .right, .topRight, .bottomRight:
            newSize.width += canvasDelta.x
        default: break
        }
        
        // vertical adjustments
        switch handle {
        case .top, .topLeft, .topRight:
            newOrigin.y += canvasDelta.y
            newSize.height -= canvasDelta.y
        case .bottom, .bottomLeft, .bottomRight:
            newSize.height += canvasDelta.y
        default: break
        }
        
        return CGRect(origin: newOrigin, size: newSize)
    }
    
    private func getScreenFrame(for canvasFrame: CGRect) -> CGRect {
        guard let viewModel else { return .zero }
        return canvasFrame
            .applying(CGAffineTransform(scaleX: viewModel.zoom, y: viewModel.zoom))
            .applying(CGAffineTransform(translationX: viewModel.panOffset.x, y: viewModel.panOffset.y))
    }
    
    private func getHandleRects(for frame: CGRect) -> [(handle: LFSelectionHandle, rectView: CGRect, rectBound: CGRect)] {
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
    
    private func drawSelectionHandles(for rect: CGRect) {
        let handles = getHandleRects(for: rect)
        
        for (_, rect, _) in handles {
            let path = NSBezierPath(rect: rect)
            NSColor(resource: .strokeFocus).setStroke()
            path.lineWidth = 2
            path.stroke()
            
            NSColor(resource: .foregroundCanvas).setFill()
            path.fill()
        }
    }
    
    private func drawSelectionBox(in context: CGContext) {
        guard let viewModel else { return }
        if viewModel.selection.isEmpty { return }
        
        var maxPoint: CGPoint? = nil
        var minPoint: CGPoint? = nil
        
        for selected in viewModel.selectionLayers {
            guard let resizeable = selected as? (any Resizable) else { continue }
            guard let max = maxPoint, let min = minPoint else {
                minPoint = selected.position
                maxPoint = CGPoint(
                    x: selected.position.x + resizeable.size.width,
                    y: selected.position.y + resizeable.size.height
                )
                continue
            }
            
            minPoint!.x = selected.position.x < min.x ? selected.position.x : min.x
            minPoint!.y = selected.position.y < min.y ? selected.position.y : min.y
            
            var point = selected.position.x + resizeable.size.width
            maxPoint!.x = point > max.x ? point : max.x
            
            point = selected.position.y + resizeable.size.height
            maxPoint!.y = point > max.y ? point : max.y
        }
        
        context.translateBy(x: viewModel.panOffset.x, y: viewModel.panOffset.y)
        
        guard let maxPoint, let minPoint else { return }
        
        // calculating scaled to maintain the lineWidth no matter zoom level
        let scaledPosition = CGPoint(
            x: minPoint.x * viewModel.zoom,
            y: minPoint.y * viewModel.zoom
        )
        let scaledSize = CGSize(
            width: (maxPoint.x - minPoint.x) * viewModel.zoom,
            height: (maxPoint.y - minPoint.y) * viewModel.zoom
        )
        let boundingBox = NSRect(origin: scaledPosition, size: scaledSize)
        let path = NSBezierPath(rect: boundingBox)
        
        NSColor(resource: .strokeFocus).setStroke()
        path.lineWidth = 2
        path.stroke()
        
        drawSelectionHandles(for: boundingBox)
    }
    
    override func magnify(with event: NSEvent) {
        guard let viewModel else { return }
        
        let mouseNow = self.convert(event.locationInWindow, from: nil)
        
        let canvasLocationUnderMouse = CGPoint(
            x: (mouseNow.x - viewModel.panOffset.x) / viewModel.zoom,
            y: (mouseNow.y - viewModel.panOffset.y) / viewModel.zoom
        )
        
        let oldZoom = viewModel.zoom
        let newZoom = max(oldZoom + event.magnification, 0.05)
        viewModel.zoom = newZoom
        
        viewModel.panOffset = CGPoint(
            x: mouseNow.x - (canvasLocationUnderMouse.x * newZoom),
            y: mouseNow.y - (canvasLocationUnderMouse.y * newZoom)
        )
    }
    
    override func scrollWheel(with event: NSEvent) {
        guard let viewModel else { return }
        
        viewModel.panOffset.x += event.scrollingDeltaX
        viewModel.panOffset.y += event.scrollingDeltaY
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let viewModel, let context = NSGraphicsContext.current?.cgContext else { return }
        
        NSColor(resource: .background).setFill()
        dirtyRect.fill()
        
        for layer in viewModel.layers {
            context.saveGState()
            
            context.translateBy(x: viewModel.panOffset.x, y: viewModel.panOffset.y)
            context.scaleBy(x: viewModel.zoom, y: viewModel.zoom)
            
            layer.draw()
            
            context.restoreGState()
        }
        
        drawSelectionBox(in: context)
    }
    
    override var isFlipped: Bool { true }
}
