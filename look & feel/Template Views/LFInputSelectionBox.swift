//
//  LFInputSelectionBox.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/2/25.
//

import SwiftUI

struct LFInputSelectionBox<
    SymbolContent: View,
    PlaceholderContent: View,
    OptionContent: View,
    T: RandomAccessCollection<String>
>: View {
    
    private enum LFFocusState: Int, CaseIterable {
        case textField = 0
        case clearButton = 1
        case optionsList = 2
    }
    
    @State private var isHovering: Bool = false
    @State private var isHoveringClear: Bool = false
    @State private var isHoveringChevron: Bool = false
    @State private var isActive: Bool = false
    @FocusState private var focus: LFFocusState?
    
    @Binding var input: String
    @Binding var selected: String
    
    let options: T
    
    let symbolContent: SymbolContent
    let placeholderContent: PlaceholderContent
    let optionContent: (String) -> OptionContent
    
    public init(
        _ selected: Binding<String>,
        input: Binding<String>,
        options: T,
        @ViewBuilder symbol: @escaping () -> SymbolContent,
        @ViewBuilder placeholder: @escaping () -> PlaceholderContent,
        @ViewBuilder option: @escaping (String) -> OptionContent
    ) {
        self._input = input
        self._selected = selected
        self.options = options
        self.symbolContent = symbol()
        self.placeholderContent = placeholder()
        self.optionContent = option
    }
    
    let predefinedHeight: CGFloat = 32
    
    var body: some View {
        let lfMouseInteractionBundle = lfMouseInteractionBundle(
            .selection,
            isHovering: isHovering,
            isFocused: focus != nil,
            hasError: false
        )
        
        let isDropDownActive: Bool = isActive || (focus == .textField && !input.isEmpty)
        
        HStack {
            symbolContent
                .onTapGesture { focus = .textField }
            
            ZStack(alignment: .leading) {
                TextField("", text: $input)
                    .textFieldStyle(.plain)
                    .focused($focus, equals: .textField)
                
                placeholderContent
                    .foregroundStyle(Color.tertiaryText)
                    .onTapGesture { focus = .textField }
                    .opacity(input.isEmpty ? 1 : 0)
            }
            
            Image(systemName: "xmark.circle.fill")
                .font(LFConst.Fonts.mediumIcon)
//                .padding(1)
//                .overlay {
//                    Circle()
//                        .stroke(
//                            Color.strokeFocus,
//                            lineWidth: LFConst.stroke
//                        )
//                        .opacity(
//                            !isHoveringClear && focus == .clearButton
//                                ? 1 : 0
//                        )
//                }
//                .focusable(true, interactions: .automatic)
//                .focused($focus, equals: .clearButton)
//                .onKeyPress(.return) {
//                    clear()
//                    return .handled
//                }
                .onTapGesture {
                    clear()
                }
                .opacity(input.isEmpty ? 0 : 1)
                .disabled(input.isEmpty)
                .focusEffectDisabled()
                .universalPointerStyle()
            
            HStack {
                Rectangle()
                    .frame(
                        width: LFConst.stroke,
                        height: predefinedHeight
                    )
                    .foregroundStyle(lfMouseInteractionBundle.stroke)
                
                Image(systemName: "chevron.down")
                    .font(LFConst.Fonts.mediumIcon)
            }
            .focusable(true, interactions: .automatic)
            .focused($focus, equals: .optionsList)
            .focusEffectDisabled()
            .padding(
                .trailing,
                LFConst.Space.small
            )
            .background(isHoveringChevron || focus == .optionsList ? Color.foreground : Color.clear)
            .onHover { isHovering in
                self.isHoveringChevron = isHovering
            }
            .onTapGesture { handleDropDownActive() }
            .onKeyPress(.return) {
                handleDropDownActive()
                return .handled
            }
            .universalPointerStyle()
        }
        .animation(.lfEaseOut, value: lfMouseInteractionBundle.id)
        .padding(
            .leading,
            LFConst.Space.small
        )
        .frame(minHeight: predefinedHeight)
        .background(lfMouseInteractionBundle.background)
        .clipShape(RoundedRectangle(cornerRadius: LFConst.Radius.regular))
        .overlay {
            RoundedRectangle(cornerRadius: LFConst.Radius.regular)
                .stroke(
                    lfMouseInteractionBundle.stroke,
                    lineWidth: LFConst.stroke
                )
                .animation(.lfEaseOut, value: lfMouseInteractionBundle.id)
        }
        .focusSection()
        .onHover { isHovering in
            self.isHovering = isHovering
        }
        .overlay(alignment: .top) {
            LFOverlayWindow(
                selected: $selected,
                height: predefinedHeight,
                options: filterOptions(input),
                optionContent: optionContent
            )
            .opacity(isDropDownActive ? 1 : 0)
            .disabled(!isDropDownActive)
        }
        .onChange(of: selected) { _, newValue in
            input = newValue
            isActive = false
            focus = nil
        }
        .onChange(of: input) { _, newValue in
            if newValue.isEmpty {
                selected = ""
            }
        }
        .zIndex(isDropDownActive ? 1 : 0)
    }
    
    private func handleDropDownActive() {
        isActive.toggle()
        focus = .optionsList
    }
    
    private func clear() {
        input = ""
        selected = ""
    }
    
    private func filterOptions(_ input: String) -> [T.Element] {
        guard !input.isEmpty else { return options.map(\.self) }
        
        return options.compactMap {
            $0.lowercased().contains(input.lowercased()) ? $0 : nil
        }
    }
}

#Preview {
    @Previewable @State var input: String = ""
    @Previewable @State var selected: String = ""
    VStack {
        Text(input)
        Text(selected)
        LFInputSelectionBox($selected, input: $input, options: ["hello", "world", "how", "are", "you", "today", "?"]) {
            Image(systemName: "magnifyingglass")
        } placeholder: {
            Text("Search fonts...")
        } option: { word in
            HStack {
                Text(word)
                Spacer()
            }
        }
    }.frame(maxWidth: 300, maxHeight: 500)
        .background(Color.foreground)
}

