//
//  DesignPanel.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//

import SwiftUI

struct DesignPanel: View {
    @ObservedObject var viewModel: ArtboardViewModel

    @State private var size: CGSize = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: LFConst.Space.medium) {
            
            // MARK: layer name
            HStack(spacing: LFConst.Space.small) {
                if let _ = viewModel.firstSelection {
                    Group {
                        Rectangle()
                            .frame(width: LFConst.Space.medium, height: LFConst.stroke)
                            .foregroundStyle(Color.darkStroke)
                        
                        Text(viewModel.firstSelectionBinding()!.name.wrappedValue)
                            .foregroundStyle(Color.tertiaryText)
                    }
                }
                
                Rectangle()
                    .frame(height: LFConst.stroke)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.darkStroke)
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
                .opacity(viewModel.firstSelection == nil ? 1 : 0)
            }
        }
    }
    
    private var designPanelContent: some View {
        VStack(alignment: .leading, spacing: LFConst.Space.medium) {
            
            // MARK: transform
            Text("Transform")
                .foregroundStyle(Color.tertiaryText)
            
            VStack(spacing: LFConst.Space.small) {
                HStack(spacing: LFConst.Space.small) {
                    VStack {
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
                        } // position vstack
                    } // end if
                    
                    if viewModel.doesFirstSelectionConform((any Resizable).self) {
                        VStack {
                            LFNumericInputBox($size.width, step: 10) {
                                Text("W:")
                            }
                            
                            LFNumericInputBox($size.height, step: 10) {
                                Text("H:")
                            }
                        } // size vstack
                        .onAppear {
                            guard let resizable = self.viewModel.firstSelectionBinding((any Resizable).self) else { return }
                            self.size = resizable.wrappedValue.size
                        }
                        .onChange(of: size) { _, newValue in
                            guard let resizable = self.viewModel.firstSelectionBinding((any Resizable).self) else { return }
                            resizable.wrappedValue.setSize(self.size)
                        }
                    } // end if
                }
                
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
        } // end inner vstack (w/ padding)
        .padding(.horizontal, LFConst.Space.medium)
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
