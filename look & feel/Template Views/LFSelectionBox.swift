//
//  LFSelectionBox.swift
//  look & feel
//
//  Created by Spencer Steadman on 9/29/25.
//

import SwiftUI

struct LFSelectionBox<
    SymbolContent: View,
    PlaceholderContent: View,
    OptionContent: View,
    T: RandomAccessCollection<String>
>: View {

    private enum LFFocusState: Int, CaseIterable {
        case chevron = 0
        case optionsList = 1
    }

    @State private var isPresentingOverlayWindow: Bool = false
    @State private var isHovering: Bool = false
    @State private var isActive: Bool = false
    @FocusState private var focus: LFFocusState?

    @Binding var selected: String

    let options: T

    let symbolContent: SymbolContent
    let placeholderContent: PlaceholderContent
    let optionContent: (String) -> OptionContent

    public init(
        _ selected: Binding<String>,
        options: T,
        @ViewBuilder placeholder: @escaping () -> PlaceholderContent,
        @ViewBuilder option: @escaping (String) -> OptionContent
    ) where SymbolContent == EmptyView {
        self._selected = selected
        self.options = options
        self.symbolContent = EmptyView()
        self.placeholderContent = placeholder()
        self.optionContent = option
    }

    public init(
        _ selected: Binding<String>,
        options: T,
        @ViewBuilder symbol: @escaping () -> SymbolContent,
        @ViewBuilder placeholder: @escaping () -> PlaceholderContent,
        @ViewBuilder option: @escaping (String) -> OptionContent
    ) {
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

        HStack(alignment: .center) {
            symbolContent
                .onTapGesture { focus = .optionsList }

            ZStack(alignment: .leading) {
                Text(selected)
                    .foregroundStyle(Color.primaryText)

                Text("Select option")
                    .foregroundStyle(Color.tertiaryText)
                    .opacity(selected.isEmpty ? 1 : 0)
            }

            Image(systemName: "chevron.down")
                .font(LFConst.Fonts.mediumIcon)
                .padding(.horizontal, LFConst.Space.small)
                .frame(height: predefinedHeight)
                .background(focus == .chevron ? Color.foreground : Color.clear)
                .focusable(true, interactions: .automatic)
                .focused($focus, equals: .chevron)
                .focusEffectDisabled()
                .onKeyPress(.return) {
                    handleDropDownActive()
                    return .handled
                }
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
        .onHover { isHovering in
            self.isHovering = isHovering
        }
        .simultaneousGesture(
            TapGesture().onEnded { handleDropDownActive() }
        )
        .overlay(alignment: .top) {
            LFOverlayWindow(
                isPresenting: $isPresentingOverlayWindow,
                selected: $selected,
                height: predefinedHeight,
                options: options,
                optionContent: optionContent
            )
            .opacity(isPresentingOverlayWindow ? 1 : 0)
            .disabled(!isPresentingOverlayWindow)
        }
        .onChange(of: isActive) { _, _ in
            updateOverlayWindowState()
        }
        .onChange(of: focus) { _, _ in
            updateOverlayWindowState()
        }
        .zIndex(isPresentingOverlayWindow ? 1 : 0)
        .universalPointerStyle()
    }

    private func updateOverlayWindowState() {
        isPresentingOverlayWindow = isActive || focus == .optionsList
    }

    private func handleDropDownActive() {
        isActive.toggle()
        focus = isActive ? .optionsList : nil
    }
}

#Preview {
    @Previewable @State var input: String = ""
    @Previewable @State var selected: String = ""
    VStack {
        LFSelectionBox($selected, options: ["hello", "world", "how", "are", "you", "today", "?", "loooooooooooooong"]) {
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
