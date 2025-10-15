//
//  InteractionBundle.swift
//  look & feel
//
//  Created by Spencer Steadman on 9/29/25.
//

import SwiftUI

enum LFException: Error {
    case unimplemented(String)
}

struct InteractionBundle: Identifiable {
    let id: UUID
    let stroke: Color
    let background: Color
    let innerShadow: Color
    let outerShadow: Color
    let shadowDepth: CGFloat
    let offset: CGSize
    
    init(
        stroke: Color,
        background: Color,
        innerShadow: Color = .clear,
        outerShadow: Color = .clear,
        shadowDepth: CGFloat = .zero,
        offset: CGSize = .zero
    ) {
        self.id = UUID()
        self.stroke = stroke
        self.background = background
        self.innerShadow = innerShadow
        self.outerShadow = outerShadow
        self.shadowDepth = shadowDepth
        self.offset = offset
    }
}

enum InteractionType {
    case button, input, selection, layer
}

func lfMouseInteractionBundle(
    _ type: InteractionType,
    isHovering: Bool,
    isFocused: Bool,
    hasError: Bool
) -> InteractionBundle {
    switch type {
    case .button:
        return lfButtonInteractionBundle(isHovering: isHovering, isFocused: isFocused)
    case .input:
        return lfInputInteractionBundle(isHovering: isHovering, isFocused: isFocused, hasError: hasError)
    case .selection:
        return lfSelectionInteractionBundle(isHovering: isHovering, isFocused: isFocused, hasError: hasError)
    case .layer:
        return lfLayerInteractionBundle(isHovering: isHovering, isFocused: isFocused)
    }
}

fileprivate func lfButtonInteractionBundle(
    isHovering: Bool,
    isFocused: Bool
) -> InteractionBundle {
    if (isFocused) {
        return InteractionBundle(
            stroke: Color.clear,
            background: Color.background,
            innerShadow: Color.shadow,
            outerShadow: Color.clear,
            shadowDepth: LFConst.shadowDepth,
            offset: CGSize(width: 0, height: 1)
        )
    } else if (isHovering) {
        return InteractionBundle(
            stroke: Color.strokeHover,
            background: Color.foreground,
            innerShadow: Color.clear,
            outerShadow: Color.shadow,
            shadowDepth: LFConst.shadowDepthHover,
            offset: .zero
        )
    }
    return InteractionBundle(
        stroke: Color.stroke,
        background: Color.foreground,
        innerShadow: Color.clear,
        outerShadow: Color.shadow,
        shadowDepth: LFConst.shadowDepth,
        offset: .zero
    )
}

fileprivate func lfInputInteractionBundle(
    isHovering: Bool,
    isFocused: Bool,
    hasError: Bool
) -> InteractionBundle {
    if (isFocused) {
        return InteractionBundle(
            stroke: hasError ? Color.strokeError : Color.strokeFocus,
            background: Color.background
        )
    } else if (isHovering) {
        return InteractionBundle(
            stroke: Color.strokeHover,
            background: Color.background
        )
    }
    return InteractionBundle(
        stroke: Color.stroke,
        background: Color.background
    )
}

fileprivate func lfSelectionInteractionBundle(
    isHovering: Bool,
    isFocused: Bool,
    hasError: Bool
) -> InteractionBundle {
    if (isFocused) {
        return InteractionBundle(
            stroke: hasError ? Color.strokeError : Color.strokeFocus,
            background: Color.background
        )
    } else if (isHovering) {
        return InteractionBundle(
            stroke: Color.strokeHover,
            background: Color.background
        )
    }
    return InteractionBundle(
        stroke: Color.stroke,
        background: Color.background
    )
}

fileprivate func lfLayerInteractionBundle(
    isHovering: Bool,
    isFocused: Bool
) -> InteractionBundle {
    if (isFocused) {
        return InteractionBundle(
            stroke: Color.clear,
            background: Color.background,
        )
    } else if (isHovering) {
        return InteractionBundle(
            stroke: Color.strokeHover,
            background: Color.foreground,
        )
    }
    return InteractionBundle(
        stroke: Color.clear,
        background: Color.foreground,
    )
}
