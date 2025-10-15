//
//  NavigationState.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//

import Foundation

class NavigationState: ObservableObject {
    // start app on artboard view
    @Published var screen: LFCanvasScreen = .artboard
}
