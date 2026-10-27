//
//  look___feelApp.swift
//  look & feel
//

import SwiftUI

@main
struct LookAndFeel: App {
    @StateObject private var navigationState = NavigationState()

    var body: some Scene {
        // `DocumentGroup` gives us the native macOS document lifecycle for free:
        // Open / Save / Save As / Recent / autosave / multi-window. Each window is
        // bound to one `LFDocumentFile` (a `.lffile` bundle).
        DocumentGroup(newDocument: LFDocumentFile()) { configuration in
            ContentView(file: configuration.$document)
                .environmentObject(navigationState)
                .frame(minWidth: 800, minHeight: 500)
        }
        .defaultSize(width: 1000, height: 600)
        .windowResizability(.contentMinSize)
    }
}
