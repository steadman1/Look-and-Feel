//
//  LFCanvasScreen.swift
//  look & feel
//
//  Created by Spencer Steadman on 11/13/25.
//


//
//  LFCanvasPanel.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//

import Foundation
import SwiftUI

struct LFCanvasScreen: Identifiable, Equatable {
    let id: UUID = UUID()
    let name: String
    let image: Image

    static let artboard: LFCanvasScreen = .init(name: "Artboard Canvas", image: Image(systemName: "pencil.and.ruler.fill"))
    static let semantic: LFCanvasScreen = .init(name: "Semantic Canvas", image: Image(systemName: "character.cursor.ibeam"))
    static let editTree: LFCanvasScreen = .init(name: "Edit Tree Canvas", image: Image(systemName: "arrow.trianglehead.branch"))

    static let allCases: [LFCanvasScreen] = [artboard, semantic, editTree]

    static func == (lhs: LFCanvasScreen, rhs: LFCanvasScreen) -> Bool {
        return lhs.id == rhs.id
    }
}
