//
//  ContentView.swift
//  look & feel
//
//  Created by Spencer Steadman on 9/22/25.
//

import SwiftUI

struct ContentView: View {
    /// The document this window is bound to (provided by `DocumentGroup`).
    @Binding var file: LFDocumentFile

    @EnvironmentObject private var navState: NavigationState

    @StateObject private var viewModel: ArtboardViewModel

    init(file: Binding<LFDocumentFile>) {
        self._file = file

        let arguments = ProcessInfo.processInfo.arguments
        let isSandbox = arguments.contains("--sandbox-viewModel")

        // In the UI-test sandbox, use the rich preview data. Otherwise seed from
        // the document so the canvas reflects the persisted design.
        let initial: ArtboardViewModel = isSandbox
            ? .preview
            : ArtboardViewModel(document: file.wrappedValue.document)

        self._viewModel = StateObject(wrappedValue: initial)
    }

    var body: some View {
        Group {
            switch navState.screen {
            case .artboard:
                ArtboardScreen(viewModel: viewModel)
            case .semantic:
                SemanticScreen()
            case .editTree:
                EditTreeScreen()
            default:
                EmptyView()
            }
        }
        // Persist: when the live layers change, write them back to the document.
        // `DocumentGroup` detects the snapshot change and autosaves. The guard
        // avoids redundant writes (and thus spurious "modified" states).
        .onChange(of: viewModel.layers) { newLayers in
            if file.document.layers != newLayers {
                var updated = file
                updated.document.layers = newLayers
                file = updated
            }
        }
    }
}

#Preview {
    ContentView(file: .constant(LFDocumentFile(document: .preview)))
        .environmentObject(NavigationState())
        .frame(width: 400, height: 300)
}
