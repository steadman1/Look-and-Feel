//
//  ArtboardToolbar.swift
//  look & feel
//
//  Created by Spencer Steadman on 11/12/25.
//

import SwiftUI

struct ArtboardToolbar: View {
    @EnvironmentObject private var navState: NavigationState

    @ObservedObject var viewModel: ArtboardViewModel

    let buttonSize: CGFloat = 32

    var body: some View {
        HStack(spacing: LFConst.Space.medium) {
            HStack(spacing: LFConst.Space.small) {
                ForEach(LFToolbarAction.allCases, id: \.id) { action in
                    LFButton(.none, isActive: .constant(viewModel.action == action)) {
                        Group {
                            action.image
                        }
                        .frame(width: buttonSize, height: buttonSize)
                    } action: {
                        viewModel.action = action
                    }
                }
            }
            .padding(LFConst.Space.small)
            .background(Color.foreground)
            .clipShape(RoundedRectangle(cornerRadius: LFConst.Radius.large))
            .padding(.bottom, LFConst.Space.medium)

            HStack(spacing: LFConst.Space.small) {
                ForEach(LFCanvasScreen.allCases, id: \.id) { screen in
                    LFButtonFlat(.none, isActive: .constant(navState.screen == screen)) {
                        Group {
                            screen.image
                        }
                        .frame(width: buttonSize, height: buttonSize)
                    } action: {
//                        navState.screen = screen
                    }
                }
            }
            .padding(LFConst.Space.small)
            .background(Color.background)
            .clipShape(RoundedRectangle(cornerRadius: LFConst.Radius.large))
            .overlay {
                RoundedRectangle(cornerRadius: LFConst.Radius.large)
                    .stroke(
                        Color.stroke,
                        lineWidth: LFConst.stroke
                    )
            }
            .padding(.bottom, LFConst.Space.medium)
        }
    }
}

#Preview {
    ArtboardToolbar(viewModel: .overloadedPreview)
}
