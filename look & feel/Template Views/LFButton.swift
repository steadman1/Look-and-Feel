//
//  StyledButton.swift
//  look & feel
//
//  Created by Spencer Steadman on 9/29/25.
//

import SwiftUI

struct LFButton<Content: View>: View {
    enum PaddingStyle {
        case parallel
        case equal
        case none
    }
    
    @State private var isHovering: Bool = false
    @State private var isMouseDown: Bool = false
    @FocusState private var isFocused: Bool
    
    @Binding private var isActive: Bool
    
    let content: Content
    let action: () -> Void
    
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    
    public init(
        _ paddingStyle: PaddingStyle = .parallel,
        @ViewBuilder content: @escaping () -> Content,
        action: @escaping () -> Void
    ) {
        self.content = content()
        self.action = action
        
        self._isActive = .constant(false)
                
        switch paddingStyle {
        case .equal:
            self.horizontalPadding = LFConst.Space.small
            self.verticalPadding = LFConst.Space.small
        case .parallel:
            self.horizontalPadding = LFConst.Space.small
            self.verticalPadding = LFConst.Space.xSmall
        default:
            self.horizontalPadding = 0
            self.verticalPadding = 0
        }
    }
    
    public init (
        _ paddingStyle: PaddingStyle = .parallel,
        isActive: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        action: @escaping () -> Void
    ) {
        self.content = content()
        self.action = action
        
        self._isActive = isActive
                
        switch paddingStyle {
        case .equal:
            self.horizontalPadding = LFConst.Space.small
            self.verticalPadding = LFConst.Space.small
        case .parallel:
            self.horizontalPadding = LFConst.Space.small
            self.verticalPadding = LFConst.Space.xSmall
        default:
            self.horizontalPadding = 0
            self.verticalPadding = 0
        }
    }
    
    var body: some View {
        let lfMouseInteractionBundle = lfMouseInteractionBundle(
            .button,
            isHovering: (isHovering || isFocused),
            isFocused: (isMouseDown || isActive),
            hasError: false
        )
        
        ZStack {
            content
        }
        .animation(.lfEaseOut, value: lfMouseInteractionBundle.id)
        .padding(
            .horizontal,
            horizontalPadding
        )
        .padding(
            .vertical,
            verticalPadding
        )
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
            content
                .offset(lfMouseInteractionBundle.offset)
                .animation(.lfEaseOut, value: lfMouseInteractionBundle.id)
        }
        .focusable(true, interactions: .automatic)
        .focused($isFocused)
        .focusEffectDisabled()
        .onKeyPress(.return, phases: .down) { _ in
            action()
            isMouseDown = true
            return .handled
        }
        .onKeyPress(.return, phases: .up) { _ in
            isMouseDown = false
            return .handled
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
}

#Preview {
    VStack {
        LFButton {
            Text("hello world")
        } action: {
            print("hello world")
        }
    }.frame(maxWidth: 300, maxHeight: 300)
        .background(Color.foreground)
}
