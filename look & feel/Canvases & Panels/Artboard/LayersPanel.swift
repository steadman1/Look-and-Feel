//
//  LayersPanel.swift
//  look & feel
//
//  Created by Spencer Steadman on 9/29/25.
//

import SwiftUI

struct LayersPanel: View {
    
    @ObservedObject var viewModel: ArtboardViewModel
    
    @State private var isShiftDown = false
    @State private var isCommandDown = false

    let majorKey: NSEvent.ModifierFlags = .shift
    
    var body: some View {
        VStack(alignment: .leading, spacing: LFConst.Space.medium) {
            
            // MARK: layer name
            HStack(spacing: LFConst.Space.small) {
                Rectangle()
                    .frame(height: LFConst.stroke)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.darkStroke)
                
                Group {
                    LFButton(.equal) {
                        Image(systemName: "arrow.down.and.line.horizontal.and.arrow.up")
                            .font(LFConst.Fonts.mediumIcon)
                    } action: {
                        collapseLayers()
                    }

                    
                    Rectangle()
                        .frame(width: LFConst.Space.medium, height: LFConst.stroke)
                        .foregroundStyle(Color.darkStroke)
                }
            }
            
            layersPanelContent
        }
        .onModifierKeysChanged { _, new in
            isShiftDown = new.contains(.shift)
            isCommandDown = new.contains(.command)
        }
    }
    
    private var layersPanelContent: some View {
        VStack {
            ForEach(viewModel.layers, id: \.id) { layer in
                LayerPreview(
                    layer,
                    isActive: viewModel.selection.contains(layer.id),
                    isFirstActive: viewModel.firstSelection == layer.id,
                    isRecentActive: viewModel.recentSelection == layer.id,
                ) {
                    if isShiftDown {
                        viewModel.multiSelect(layer.id)
                    } else if isCommandDown {
                        viewModel.toggleSelection(layer.id)
                    } else {
                        viewModel.singleSelect(layer.id)
                    }
                }
            }
        }
        .padding(.horizontal, LFConst.Space.medium)
    }
    
    private func collapseLayers() { }
}

struct LayerPreview: View {
    @State private var isHovering: Bool = false
    @State private var isMouseDown: Bool = false
    
    let layer: LFLayer
    let isActive: Bool
    let isFirstActive: Bool
    let isRecentActive: Bool
    let action: () -> Void
    
    init(
        _ layer: LFLayer,
        isActive: Bool,
        isFirstActive: Bool,
        isRecentActive: Bool,
        action: @escaping () -> Void
    ) {
        self.layer = layer
        self.isActive = isActive
        self.isFirstActive = isFirstActive
        self.isRecentActive = isRecentActive
        self.action = action
    }
    
    var body: some View {
        let lfMouseInteractionBundle = lfMouseInteractionBundle(
            .layer,
            isHovering: isHovering,
            isFocused: (isMouseDown || isActive),
            hasError: false
        )
        
        layerContent(lfMouseInteractionBundle)
            .background(lfMouseInteractionBundle.background)
            .clipShape(RoundedRectangle(cornerRadius: LFConst.Radius.regular))
            .shadow(
                color: lfMouseInteractionBundle.outerShadow,
                radius: 0,
                x: 0,
                y: lfMouseInteractionBundle.shadowDepth
            )
            .overlay {
                RoundedRectangle(cornerRadius: LFConst.Radius.regular)
                    .stroke(
                        lfMouseInteractionBundle.stroke,
                        lineWidth: LFConst.stroke
                    )
                    .fill(
                        lfMouseInteractionBundle.background
                        .shadow(
                            .inner(
                                color: lfMouseInteractionBundle.innerShadow,
                                radius: 1,
                                x: 0,
                                y: lfMouseInteractionBundle.shadowDepth
                            )
                        )
                    )
                    .animation(.lfEaseOut, value: lfMouseInteractionBundle.id)
            }
            .overlay {
                layerContent(lfMouseInteractionBundle)
            }
            .onHover { isHovering in
                self.isHovering = isHovering
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isMouseDown = true }
                    .onEnded { _ in
                        action()
                        isMouseDown = false
                    }
            )
            .universalPointerStyle()
    }
    
    @ViewBuilder
    private func layerContent(
        _ lfMouseInteractionBundle: InteractionBundle
    ) -> some View {
        HStack {
            layer.symbol
                .foregroundStyle(Color.tertiaryText)
            
            Text(layer.name)
                .foregroundStyle(Color.primaryText)
            
            Spacer()

            if isFirstActive && isRecentActive {
                ZStack {
                    Circle()
                        .foregroundStyle(Color.mark)
                        .frame(width: 6, height: 6)

                    Circle()
                        .stroke(Color.background, lineWidth: 3)
                        .fill(Color.focus)
                        .frame(width: 6, height: 6)
                        .offset(x: -5)
                }
            } else if isFirstActive {
                Circle()
                    .foregroundStyle(Color.mark)
                    .frame(width: 6, height: 6)
            } else if isRecentActive {
                Circle()
                    .fill(Color.focus)
                    .frame(width: 6, height: 6)
            }

        }
        .offset(lfMouseInteractionBundle.offset)
        .animation(.lfEaseOut, value: lfMouseInteractionBundle.id)
        .padding(LFConst.Space.small)
    }
}

#Preview {
    LFPreviewPanelWrapper(name: "Design") {
        LayersPanel(viewModel: .preview)
    }
    .frame(width: 300, height: 500)
}
