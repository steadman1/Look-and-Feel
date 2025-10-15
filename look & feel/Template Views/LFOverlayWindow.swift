//
//  LFOverlayWindow.swift
//  look & feel
//
//  Created by Spencer Steadman on 9/30/25.
//

import SwiftUI

struct LFOverlayWindow<OptionContent: View, T: RandomAccessCollection<String>>: View {
    
    @State private var scrollViewContentSize: CGSize = .zero
    @State private var scrollPosition: String? = nil
    
    @Binding var selected: String
    
    let height: CGFloat
    let options: T
    let optionContent: (String) -> OptionContent
    
    let maxHeight: CGFloat = 128
    
    var body: some View {
        VStack(alignment: .leading) {
            if !options.isEmpty {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 1) {
                        ForEach(0..<options.count, id: \.self) { index in
                            let option = options[index as! T.Index]
                            LFOverlayWindowSelection(
                                $selected,
                                scrollPosition: $scrollPosition,
                                optionString: option
                            ) {
                                optionContent(option)
                            }
                        }
                    }
                    .padding(.all, LFConst.Space.xSmall)
                    .background(
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                scrollViewContentSize = geo.size
                            }
                            return Color.clear
                        }
                    )
                }
                .frame(height: min(scrollViewContentSize.height, maxHeight))
                .scrollPosition(id: $scrollPosition)
                .focusSection()
                
            } else {
                Text("No options found.")
                    .foregroundStyle(Color.tertiaryText)
            }
        }
        .frame(maxHeight: maxHeight)
        .frame(maxWidth: .infinity)
        .background(Color.background)
        .clipShape(RoundedRectangle(cornerRadius: LFConst.Radius.regular))
        .overlay {
            RoundedRectangle(cornerRadius: LFConst.Radius.regular)
                .stroke(
                    Color.stroke,
                    lineWidth: LFConst.stroke
                )
        }
        .offset(y: height + LFConst.stroke * 2)
        .universalPointerStyle()
    }
}

struct LFOverlayWindowSelection<OptionContent: View>: View {
    
    @State private var isHovering: Bool = false
    @FocusState private var isFocused: Bool
    
    @Binding var selected: String
    @Binding var scrollPosition: String?
    
    let optionString: String
    let optionContent: OptionContent
    
    init(
        _ selected: Binding<String>,
        scrollPosition: Binding<String?>,
        optionString: String,
        @ViewBuilder option: @escaping () -> OptionContent
    ) {
        self._selected = selected
        self._scrollPosition = scrollPosition
        self.optionString = optionString
        self.optionContent = option()
    }
    
    var body: some View {
        HStack {
            optionContent
        }
        .frame(maxWidth: .infinity)
        .padding(
            .horizontal,
            LFConst.Space.small
        )
        .padding(
            .vertical,
            LFConst.Space.xSmall
        )
        .background(
            isHovering ? Color.foreground : Color.background
        )
        .clipShape(RoundedRectangle(cornerRadius: LFConst.Radius.small))
        .focusable(true, interactions: .automatic)
        .focused($isFocused)
        .focusEffectDisabled()
        .overlay {
            if isFocused {
                RoundedRectangle(cornerRadius: LFConst.Radius.small)
                    .stroke(
                        Color.strokeFocus,
                        lineWidth: LFConst.stroke
                    )
            }
        }
        .onHover { isHovering in
            self.isHovering = isHovering
        }
        .onTapGesture { handleSelected() }
        .onKeyPress(.return) {
            if !isFocused { return .ignored }
            
            handleSelected()
            return .handled
        }
        .onChange(of: isFocused) { _, newValue in
            if newValue {
                scrollPosition = optionString
            }
        }
        .id(optionString)
    }
    
    private func handleSelected() {
        selected = optionString
    }
}
