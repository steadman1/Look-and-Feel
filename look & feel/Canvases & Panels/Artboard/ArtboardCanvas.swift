//
//  ArtboardCanvas.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//

import SwiftUI

struct ArtboardCanvas: View {
    @EnvironmentObject private var navState: NavigationState

    @ObservedObject var viewModel: ArtboardViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                NSArtboardCanvasViewRepresentable(
                    viewModel: viewModel,
                    frame: geometry.frame(in: .local)
                )

                ArtboardToolbar(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ArtboardCanvas(viewModel: .preview)
        .frame(width: 300, height: 300)
}
