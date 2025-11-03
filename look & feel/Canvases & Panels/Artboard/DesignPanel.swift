//
//  DesignPanel.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//

import SwiftUI

struct DesignPanel: View {
    @ObservedObject var viewModel: ArtboardViewModel

    @State private var fontFamilyInput: String = ""
    @State private var fontFamilies: [String] = []
    @State private var fontMembers: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: LFConst.Space.medium) {
            
            // MARK: layer name
            HStack(spacing: LFConst.Space.small) {
                if let id = viewModel.recentSelection {
                    Group {
                        Rectangle()
                            .frame(width: LFConst.Space.small, height: LFConst.stroke)
                            .foregroundStyle(Color.darkStroke)

                        Text(viewModel.firstSelectionBinding()!.name.wrappedValue)
                            .foregroundStyle(Color.tertiaryText)

                        let isFirstSelected = id == viewModel.firstSelection
                        ZStack {
                            Circle()
                                .foregroundStyle(Color.mark)
                                .frame(width: 6, height: 6)
                                .offset(x: isFirstSelected ? 5 : 0)

                            if isFirstSelected {
                                Circle()
                                    .stroke(Color.foreground, lineWidth: 3)
                                    .fill(Color.focus)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .animation(.lfEaseOut, value: isFirstSelected)
                    }
                }
                
                dividerContent
            }
            
            if (viewModel.firstSelection != nil) {
                designPanelContent
            } else {
                VStack(alignment: .center) {
                    Spacer()
                    
                    Text("Select a Layer")
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var designPanelContent: some View {
        VStack(alignment: .leading, spacing: LFConst.Space.medium) {

            // MARK: transform & resize
            Group {
                Text("Transform")
                    .foregroundStyle(Color.tertiaryText)

                VStack(spacing: LFConst.Space.small) {
                    HStack(spacing: LFConst.Space.small) {
                        // all layers must conform to transformable
                        transformableContent

                        if viewModel.doesFirstSelectionConform((any Resizable).self) {
                            resizableContent
                        }
                    }

                    // all layers conform to transformable
                    rotationContent
                }
            }
            .padding(.horizontal, LFConst.Space.medium)

            dividerContent

            if viewModel.doesFirstSelectionConform((any Typographic).self) {
                typographicContent
            }
        }
    }

    // MARK: typographic content
    @ViewBuilder
    private var typographicContent: some View {
        let text = self.viewModel.firstSelectionBinding((any Typographic).self)!
        let bindingFontFamily = Binding<String>(
            get: { text.wrappedValue.fontFamily },
            set: { text.wrappedValue.setFont($0, with: "") }
        )
        let bindingFontMember = Binding<String>(
            get: { text.wrappedValue.fontMember },
            set: { text.wrappedValue.setFont(fontFamilyInput, with: $0) }
        )
        let bindingFontSize = Binding<CGFloat>(
            get: { text.wrappedValue.fontSize },
            set: { text.wrappedValue.setFontSize($0) }
        )
        let bindingLeading = Binding<CGFloat>(
            get: { text.wrappedValue.leading },
            set: { text.wrappedValue.setLeading($0) }
        )
        let bindingTracking = Binding<CGFloat>(
            get: { text.wrappedValue.tracking },
            set: { text.wrappedValue.setTracking($0) }
        )

        Group {
            // MARK: transform & resize
            Text("Typography")
                .foregroundStyle(Color.tertiaryText)

            VStack(spacing: LFConst.Space.small) {
                LFInputSelectionBox(
                    bindingFontFamily,
                    input: $fontFamilyInput,
                    options: fontFamilies
                ) {
                    Image(systemName: "magnifyingglass")
                } placeholder: {
                    Text("Search fonts...")
                } option: { option in
                    HStack {
                        Text(option)
                            .font(.custom(option, size: 12))
                        Spacer()
                    }
                }

                LFSelectionBox(
                    bindingFontMember,
                    options: fontMembers
                ) {
                    Text("Font Members...")
                } option: { option in
                    let optionName = option.split(separator: "-").last
                    HStack {
                        Text(optionName?.description ?? option)
                            .font(.custom(option, size: 12))
                        Spacer()
                    }
                }


                HStack {
                    // MARK: font size
                    LFNumericInputBox(
                        bindingFontSize,
                        step: 1
                    ) {
                        HStack(spacing: 0) {
                            Image(systemName: "textformat.size")
                            Text(":")
                        }
                    }
                }

                HStack {
                    // MARK: leading (line spacing)
                    LFNumericInputBox(
                        bindingLeading,
                        step: 1
                    ) {
                        HStack(spacing: 0) {
                            Image(systemName: "arrow.up.and.down.text.horizontal")
                            Text(":")
                        }
                    }

                    // MARK: tracking (letter spacing)
                    LFNumericInputBox(
                        bindingTracking,
                        step: 1
                    ) {
                        HStack(spacing: 0) {
                            Image(systemName: "textformat.characters.arrow.left.and.right")
                            Text(":")
                        }
                    }
                }
            }
        }
        .padding(.horizontal, LFConst.Space.medium)
        .onAppear {
            DispatchQueue.main.async {
                fontFamilies = NSFont.getAllFontFamilies()
                fontMembers = NSFont.getAllFontMembers(for: fontFamilyInput)
            }
        }
        .onChange(of: fontFamilyInput) { _, newValue in
            fontMembers = NSFont.getAllFontMembers(for: newValue)
        }
    }

    // MARK: transformable content
    @ViewBuilder
    private var transformableContent: some View {
        VStack(spacing: LFConst.Space.small) {
            LFNumericInputBox(
                viewModel.firstSelectionBinding()!.position.x,
                step: 1
            ) {
                Text("X:")
            }

            LFNumericInputBox(
                viewModel.firstSelectionBinding()!.position.y,
                step: 1
            ) {
                Text("Y:")
            }
        } // position vstack
    }

    @ViewBuilder
    private var rotationContent: some View {
        HStack {
            LFNumericInputBox(
                viewModel.firstSelectionBinding()!.rotation,
                step: 1
            ) {
                HStack(spacing: 0) {
                    Image(systemName: "angle")
                    Text(":")
                }
            } placeholder: {
                Text("Number")
            } unit: {
                Text("deg")
            }
        }
    }

    // MARK: resizable content
    @ViewBuilder
    private var resizableContent: some View {
        let resizable = self.viewModel.firstSelectionBinding((any Resizable).self)!
        let bindingSize = Binding<CGSize>(
            get: { resizable.wrappedValue.size },
            set: { resizable.wrappedValue.setSize($0) }
        )

        VStack {
            LFNumericInputBox(bindingSize.width, step: 10) {
                Text("W:")
            }

            LFNumericInputBox(bindingSize.height, step: 10) {
                Text("H:")
            }
        }
    }

    // MARK: divider
    @ViewBuilder
    private var dividerContent: some View {
        Rectangle()
            .frame(height: LFConst.stroke)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.darkStroke)
    }
}

#Preview("Design Panel w/ Content") {
    LFPreviewPanelWrapper(name: "Design") {
        DesignPanel(viewModel: ArtboardViewModel.preview)
    }
    .frame(width: 300, height: 500)
}

#Preview("Design Panel w/o Content") {
    LFPreviewPanelWrapper(name: "Design") {
        DesignPanel(viewModel: ArtboardViewModel())
    }
    .frame(width: 300, height: 500)
}
