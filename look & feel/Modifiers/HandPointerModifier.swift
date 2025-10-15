//
//  HandPointerModifier.swift
//  look & feel
//
//  Created by Google Gemini on 9/30/25.
//  Edited by Spencer Steadman on 9/30/25.
//


import SwiftUI

// Only import AppKit on macOS where NSCursor is available
#if canImport(AppKit)
import AppKit
#endif

enum UniversalPointerStyle {
    case arrow
    case closedHand
    case openHand
    case pointingHand
    case iBeam
    case resizeLeft
    case resizeRight
    case resizeLeftRight
    case resizeUp
    case resizeDown
    case resizeUpDown
    case iBeamCursorForVerticalLayout
    case operationNotAllowed
    case disappearingItem
    case contextualMenu
    case dragCopy
    case dragLink
}

/**
 A custom ViewModifier that applies the `pointingHand` cursor
 for hover interactions, using the modern `.pointer(.hand)` API
 when available (macOS 15.0+), and falling back to AppKit's
 NSCursor for compatibility.
 */
struct HandPointerModifier: ViewModifier {
    let style: UniversalPointerStyle
    
    func body(content: Content) -> some View {
        content
            .onHover { isHovered in
                // DispatchQueue.main.async is good practice when interacting
                // with AppKit/UIKit objects from within SwiftUI's onHover closure.
                DispatchQueue.main.async {
                    if isHovered {
                        
                        // Show the pointing hand cursor
                        switchCursor(style).push()
                    } else {
                        // Restore the previous cursor
                        NSCursor.pop()
                    }
                }
            }
    }
    
    private func switchCursor(_ style: UniversalPointerStyle) -> NSCursor {
        switch style {
        case .arrow:
            return .arrow
        case .closedHand:
            return .closedHand
        case .openHand:
            return .openHand
        case .pointingHand:
            return .pointingHand
        case .iBeam:
            return .iBeam
        case .resizeLeft:
            if #available(macOS 15.0, *) {
                return .columnResize(directions: .left)
            } else {
                return .resizeLeft
            }
        case .resizeRight:
            if #available(macOS 15.0, *) {
                return .columnResize(directions: .right)
            } else {
                return .resizeRight
            }
        case .resizeLeftRight:
            if #available(macOS 15.0, *) {
                return .columnResize(directions: .all)
            } else {
                return .resizeLeftRight
            }
        case .resizeUp:
            if #available(macOS 15.0, *) {
                return .rowResize(directions: .up)
            } else {
                return .resizeUp
            }
        case .resizeDown:
            if #available(macOS 15.0, *) {
                return .rowResize(directions: .down)
            } else {
                return .resizeDown
            }
        case .resizeUpDown:
            if #available(macOS 15.0, *) {
                return .rowResize(directions: .all)
            } else {
                return .resizeUpDown
            }
        case .iBeamCursorForVerticalLayout:
            return .iBeamCursorForVerticalLayout
        case .operationNotAllowed:
            return .operationNotAllowed
        case .disappearingItem:
            return .disappearingItem
        case .contextualMenu:
            return .contextualMenu
        case .dragCopy:
            return .dragCopy
        case .dragLink:
            return .dragLink
        }
    }
}

// MARK: - Convenience Extension

extension View {
    /// Applies the hand/pointing cursor on hover for macOS targets.
    /// Uses `.pointer(.hand)` on modern OS and NSCursor on older OS.
    func universalPointerStyle(_ style: UniversalPointerStyle = .pointingHand) -> some View {
        self.modifier(HandPointerModifier(style: style))
    }
}
