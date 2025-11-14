//
//  LFToolbarAction.swift
//  look & feel
//
//  Created by Spencer Steadman on 11/12/25.
//

import Foundation
import SwiftUI

struct LFToolbarAction: Identifiable, Equatable {
    let id: UUID = UUID()
    let name: String
    let image: Image

    static let selection: LFToolbarAction = .init(name: "Selection", image: Image(systemName: "hand.tap"))
    static let directSelection: LFToolbarAction = .init(name: "Direct Selection", image: Image(systemName: "hand.tap.fill"))
    static let pen: LFToolbarAction = .init(name: "Pen", image: Image(systemName: "pencil.tip"))
    static let polygon: LFToolbarAction = .init(name: "Polygon", image: Image(systemName: "rectangle.portrait"))
    static let marker: LFToolbarAction = .init(name: "Marker", image: Image(systemName: "paintbrush.pointed.fill"))
    static let erase: LFToolbarAction = .init(name: "Erase", image: Image(systemName: "eraser.fill"))
    static let text: LFToolbarAction = .init(name: "Text", image: Image(systemName: "textformat"))
    static let rotate: LFToolbarAction = .init(name: "Rotate", image: Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90"))
    static let shear: LFToolbarAction = .init(name: "Shear", image: Image(systemName: "inset.filled.trailinghalf.arrow.trailing.rectangle"))
    static let scale: LFToolbarAction = .init(name: "Scale", image: Image(systemName: "rectangle.expand.diagonal"))

    static let allCases: [LFToolbarAction] = [selection, directSelection, pen, polygon, marker, erase, text, rotate, shear, scale]

    static func == (lhs: LFToolbarAction, rhs: LFToolbarAction) -> Bool {
        return lhs.id == rhs.id
    }
}
