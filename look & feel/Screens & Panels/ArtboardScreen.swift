//
//  ArtboardCanvasScreen.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//

import SwiftUI

struct ArtboardScreen: View {
    @EnvironmentObject private var navState: NavigationState
    
    @ObservedObject var viewModel: ArtboardViewModel
    
    @State private var leadingPanelState: LFArtboardLeadingPanel = .layers
    @State private var trailingPanelState: LFArtboardTrailingPanel = .design
    
    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                panelsWrapper(
                    allCases: LFArtboardLeadingPanel.allCases,
                    state: leadingPanelState.rawValue
                ) {
                    switch leadingPanelState {
                    case .layers:
                        LayersPanel(viewModel: viewModel)
                    }
                } action: { rawValue in
                    leadingPanelState = LFArtboardLeadingPanel(rawValue: rawValue) ?? .layers
                }
                .frame(width: 300)
                .zIndex(2)
                
                ArtboardCanvas(viewModel: viewModel)
                    .frame(maxWidth: proxy.size.width - 600)
                    .zIndex(1)
                
                panelsWrapper(
                    allCases: LFArtboardTrailingPanel.allCases,
                    state: trailingPanelState.rawValue
                ) {
                    switch trailingPanelState {
                    case .design:
                        DesignPanel(viewModel: viewModel)
                    case .constants:
                        Text("hello world")
                    }
                } action: { rawValue in
                    trailingPanelState = LFArtboardTrailingPanel(rawValue: rawValue) ?? .design
                }
                .frame(width: 300)
                .zIndex(2)
            }
        }
    }
    
    private func panelsWrapper<T: PanelCase>(
        allCases: [T],
        state: Int,
        @ViewBuilder _ content: @escaping () -> some View,
        action: @escaping (Int) -> Void
    ) -> some View {
        
        ScrollView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(allCases, id: \.rawValue) { lfcase in
                            let rawValue = lfcase.rawValue as! Int
                            
                            LFButton(
                                // visually active only if there's
                                // more than 1 case/LFButton
                                isActive: .constant(
                                    state == rawValue && allCases.count > 1
                                )
                            ) {
                                Text(lfcase.description)
                            } action: {
                                action(rawValue)
                            }

                        }
                    }
                    .padding([.top, .horizontal], LFConst.Space.medium)
                    .padding(.vertical, LFConst.shadowDepthHover)
                }
                
                content()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.foreground)
    }
}

#Preview {
    ArtboardScreen(viewModel: .preview)
        .environmentObject(NavigationState())
}
