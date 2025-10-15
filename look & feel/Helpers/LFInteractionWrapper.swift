//
//  LFInteractionWrapper.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import SwiftUI
import Combine
import AppKit

struct LFInteractionWrapper<Content: View>: View {
    
    @State private var timerActive: Bool = false
    @State private var cancellable: AnyCancellable?
    @State private var isMajorKeyDown: Bool = false
    
    let onTap: () -> Void
    let onMajorTap: () -> Void
    let onHold: () -> Void
    let onMajorHold: () -> Void
    let content: Content
    
    let majorKey: NSEvent.ModifierFlags
    
    init(
        majorKey: NSEvent.ModifierFlags = .shift,
        onTap: @escaping () -> Void,
        onMajorTap: (() -> Void)? = nil,
        onHold: @escaping () -> Void,
        onMajorHold: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.majorKey = majorKey
        self.onTap = onTap
        self.onMajorTap = onMajorTap ?? onTap
        self.onHold = onHold
        self.onMajorHold = onMajorHold ?? onHold
        self.content = content()
    }
    
    var body: some View {
        content
            .focusable(true, interactions: .automatic)
            .focusEffectDisabled()
            .onTapGesture {
                if isMajorKeyDown {
                    onMajorTap()
                } else {
                    onTap()
                }
            }
            .onLongPressGesture {
                if isMajorKeyDown {
                    onMajorHold()
                } else {
                    onHold()
                }
                
                timerActive = true
                cancellable = Timer.publish(every: 0.05, on: .main, in: .common)
                    .autoconnect()
                    .sink { _ in
                        if isMajorKeyDown {
                            onMajorHold()
                        } else {
                            onHold()
                        }
                    }
                    
            } onPressingChanged: { isPressing in
                timerActive = false
                cancellable?.cancel()
                cancellable = nil
            }
            .onKeyPress(.return) {
                onTap()
                return .handled
            }
            .onModifierKeysChanged { _, new in
                isMajorKeyDown = new.contains(.shift)
            }
            .universalPointerStyle()
    }
}
