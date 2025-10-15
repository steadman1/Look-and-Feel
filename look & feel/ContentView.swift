//
//  ContentView.swift
//  look & feel
//
//  Created by Spencer Steadman on 9/22/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var navState: NavigationState
    
    @StateObject private var viewModel = ArtboardViewModel.preview

    var body: some View {
        switch navState.screen {
        case .artboard:
            ArtboardScreen(viewModel: viewModel)
        case .semantic:
            SemanticScreen()
        case .editTree:
            EditTreeScreen()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NavigationState())
        .frame(width: 400, height: 300)
}
