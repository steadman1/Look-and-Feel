//
//  ArtboardCanvas.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//

import SwiftUI

struct ArtboardCanvas: View {
    
    @ObservedObject var viewModel: ArtboardViewModel
    
    var body: some View {
        GeometryReader { geometry in
            NSArtboardCanvasViewRepresentable(
                viewModel: viewModel,
                frame: geometry.frame(in: .local)
            )
        }
    }
}

#Preview {
    ArtboardCanvas(viewModel: .preview)
        .frame(width: 300, height: 300)
}
