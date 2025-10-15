//
//  Typographic.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import CoreGraphics

enum ParagraphStyle: Int, Hashable, CaseIterable {
    case left, center, right, leftJustified, centerJustified, rightJustified
}

protocol Typographic {
    var fontName: String { get set }
    var fontSize: Double { get set }
    var leading: CGFloat { get set }
    var letterSpacing: CGFloat { get set }
    var paragraphStyle: ParagraphStyle { get set }
}
