//
//  ArtboardCanvasView.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import AppKit
import SwiftUI

struct NSArtboardCanvasViewRepresentable: NSViewRepresentable {
    
    @ObservedObject var viewModel: ArtboardViewModel

    var frame: NSRect

    func makeNSView(context: Context) -> CanvasView {
        return CanvasView(frame: frame, viewModel: viewModel)
    }

    func updateNSView(_ nsView: CanvasView, context: Context) {
        nsView.viewModel = viewModel
        nsView.frame = frame
    }
}
