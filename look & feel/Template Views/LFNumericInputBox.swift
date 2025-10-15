//
//  LFNumericInputBox.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/2/25.
//

import SwiftUI

struct LFNumericInputBox<LabelContent: View, PlaceholderContent: View, UnitContent: View>: View {
    
    private enum LFFocusState: Int, CaseIterable {
        case textField = 0
        case upChevron = 1
        case downChevron = 2
    }
    
    private enum HoverState: Int, CaseIterable {
        case textField = 0
        case upChevron = 1
        case downChevron = 2
    }
    
    @State private var isInputNumber: Bool = true
    @State private var hover: HoverState?
    @State private var isMouseDown: Bool = false
    @State private var isActive: Bool = false
    @FocusState private var focus: LFFocusState?
    
    @State private var input: String = ""
    @Binding private var binding: CGFloat
    
    let step: Double
    
    let hasLabelContent: Bool
    let labelContent: LabelContent
    let placeholderContent: PlaceholderContent
    let unitContent: UnitContent
    
    public init(
        _ binding: Binding<CGFloat>,
        step: Double = 1
    ) where LabelContent == EmptyView, PlaceholderContent == Text, UnitContent == Text {
        self._binding = binding
        self.input = binding.wrappedValue.toString()
        self.step = step
        self.hasLabelContent = false
        self.labelContent = EmptyView()
        self.placeholderContent = Text("Number")
        self.unitContent = Text("pt")
    }
    
    public init(
        _ binding: Binding<CGFloat>,
        step: Double = 1,
        @ViewBuilder label: @escaping () -> LabelContent,
    ) where PlaceholderContent == Text, UnitContent == Text {
        self._binding = binding
        self.input = binding.wrappedValue.toString()
        self.step = step
        self.hasLabelContent = true
        self.labelContent = label()
        self.placeholderContent = Text("Number")
        self.unitContent = Text("pt")
    }
    
    public init(
        _ binding: Binding<CGFloat>,
        step: Double = 1,
        @ViewBuilder label: @escaping () -> LabelContent,
        @ViewBuilder placeholder: @escaping () -> PlaceholderContent,
        @ViewBuilder unit: @escaping () -> UnitContent
    ) {
        self._binding = binding
        self.input = binding.wrappedValue.toString()
        self.step = step
        self.hasLabelContent = true
        self.labelContent = label()
        self.placeholderContent = placeholder()
        self.unitContent = unit()
    }
    
    let predefinedHeight: CGFloat = 32
    
    var body: some View {
        let lfMouseInteractionBundle = lfMouseInteractionBundle(
            .input,
            isHovering: hover != nil,
            isFocused: focus != nil,
            hasError: !isInputNumber
        )
        
        HStack(spacing: 0) {
            if hasLabelContent {
                labelContent
                    .frame(
                        width: predefinedHeight,
                        height: predefinedHeight,
                        alignment: .leading
                    )
            }
            
            HStack {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        LFInteractionWrapper(majorKey: .shift) {
                            handleClick(step)
                        } onMajorTap: {
                            handleClick(step * 10)
                        } onHold: {
                            handleClick(step)
                        } onMajorHold: {
                            handleClick(step * 10)
                        } content: {
                            Image(systemName: "chevron.up")
                                .font(LFConst.Fonts.smallIcon)
                                .padding(
                                    .top,
                                    LFConst.Space.xSmall
                                )
                                .frame(height: predefinedHeight / 2)
                                .padding(
                                    .horizontal,
                                    LFConst.Space.small
                                )
                                .background(hover == .upChevron || focus == .upChevron ? Color.foreground : Color.clear)
                                .focused($focus, equals: .upChevron)
                                .onHover { isHovering in
                                    self.hover = .upChevron
                                }
                        }
                        
                        LFInteractionWrapper(majorKey: .shift) {
                            handleClick(-step)
                        } onMajorTap: {
                            handleClick(-step * 10)
                        } onHold: {
                            handleClick(-step)
                        } onMajorHold: {
                            handleClick(-step * 10)
                        } content: {
                            Image(systemName: "chevron.down")
                                .font(LFConst.Fonts.smallIcon)
                                .padding(
                                    .bottom,
                                    LFConst.Space.xSmall
                                )
                                .frame(height: predefinedHeight / 2)
                                .padding(
                                    .horizontal,
                                    LFConst.Space.small
                                )
                                .background(hover == .downChevron || focus == .downChevron ? Color.foreground : Color.clear)
                                .focused($focus, equals: .downChevron)
                                .onHover { isHovering in
                                    self.hover = .downChevron
                                }
                        }
                    }
                        
                    
                    Rectangle()
                        .frame(
                            width: LFConst.stroke,
                            height: predefinedHeight
                        )
                        .foregroundStyle(lfMouseInteractionBundle.stroke)
                }
                
                
                ZStack(alignment: .leading) {
                    TextField("", text: $input)
                        .textFieldStyle(.plain)
                        .focusable(true, interactions: .automatic)
                        .focused($focus, equals: .textField)
                        .focusEffectDisabled()
                        .onChange(of: input) { validateInputAsDouble($1) }
                        .onChange(of: binding) { input = binding.toString() }
                        .onChange(of: focus) { _, newValue in
                            if newValue != .textField {
                                input = binding.toString()
                            }
                        }
                    
                    if input.isEmpty {
                        placeholderContent
                            .foregroundStyle(Color.tertiaryText)
                            .onTapGesture { focus = .textField }
                    }
                }
                
                unitContent
                    .foregroundStyle(Color.tertiaryText)
            }
            .animation(.lfEaseOut, value: lfMouseInteractionBundle.id)
            .padding(
                .trailing,
                LFConst.Space.small
            )
            .background(lfMouseInteractionBundle.background)
            .clipShape(RoundedRectangle(cornerRadius: LFConst.Radius.regular))
            .overlay {
                RoundedRectangle(cornerRadius: LFConst.Radius.regular)
                    .stroke(
                        isInputNumber
                            ? lfMouseInteractionBundle.stroke
                            : Color.strokeError,
                        lineWidth: LFConst.stroke
                    )
                    .animation(.lfEaseOut, value: lfMouseInteractionBundle.id)
            }
            .focusSection()
            .onHover { _ in
                self.hover = .textField
            }
        }
    }
    
    private func handleClick(_ adding: CGFloat) {
        binding += adding
    }
    
    private func validateInputAsDouble(_ newValue: String) {
        do {
            if newValue.isEmpty {
                binding = 0.0
                return
            }
            
            binding = try Double(
                newValue,
                format: .number,
                lenient: false
            )
            
            isInputNumber = true
        } catch {
            isInputNumber = false
        }
    }
}

#Preview {
    @Previewable @State var input: CGFloat = 0
    VStack {
        LFNumericInputBox($input, step: 0.25) {
           Text("X:")
        } placeholder: {
            Text("Number")
        } unit: {
            Text("pt")
        }
    }.frame(maxWidth: 300, maxHeight: 300)
        .background(Color.foreground)
}
