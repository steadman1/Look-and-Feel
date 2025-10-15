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
        NSArtboardCanvasViewRepresentable(viewModel: viewModel)
    }
}

#Preview {
    ArtboardCanvas(viewModel: .preview)
        .frame(width: 300, height: 300)
}
