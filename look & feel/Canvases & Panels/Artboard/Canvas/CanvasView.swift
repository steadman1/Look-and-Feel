//
//  CanvasView.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import AppKit
import SwiftUI

public class CanvasView: NSView {

    init(frame: NSRect, viewModel: ArtboardViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = coder.decodeObject(forKey: "viewModel") as? ArtboardViewModel ?? .init()
        super.init(coder: coder)
    }

    var viewModel: ArtboardViewModel {
        didSet {
            self.needsDisplay = true
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupTrackingArea()
    }
    
    func setupTrackingArea() {
        let options: NSTrackingArea.Options = [.inVisibleRect, .activeAlways, .mouseMoved]
        let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }
    
    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) }
        setupTrackingArea()
    }

    public override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        NSColor(resource: .background).setFill()
        dirtyRect.fill()

        drawLFLayers(in: context)

        // MARK: draw objects that require constant line width regardless of zoom
        // all functions here must scale each object's size by zoom amount and translate
        // objects accordingly after scaling (scaling will affect location on canvas)
        context.saveGState()
        context.translateBy(x: viewModel.panOffset.x, y: viewModel.panOffset.y)

        drawAxes(in: context)
        drawSelectionBox(in: context)
        drawSelectionHandles(in: context)

        context.restoreGState()
    }
    
    public override var isFlipped: Bool { true }

    // MARK: misc. helper functions
    internal func handleTransformRequests(
        for requests: [LFCanvasTransformRequest]
    ) -> (
        translation: CGPoint,
        zoom: CGFloat,
        rotation: CGFloat
    ) {
        var translation: CGPoint = .zero
        var zoom: CGFloat = 1
        /* var */ let rotation: CGFloat = 0

        for request in requests {
            switch request {
            case .translate:
                translation = viewModel.panOffset
            case .zoom:
                zoom = viewModel.zoom
            case .rotate:
                continue
            }
        }

        return (translation, zoom, rotation)
    }
}
