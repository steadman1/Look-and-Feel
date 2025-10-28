//
//  Typographic.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import CoreGraphics
import Foundation

enum LFTypeStyle: Int, Hashable, CaseIterable {
    case point, paragraph
}

protocol Typographic {
    var fontName: String { get }
    var fontSize: Double { get set }
    var attributedString: NSAttributedString { get set }
    var leading: CGFloat { get set }
    var letterSpacing: CGFloat { get set }
    var typeStyle: LFTypeStyle { get set }
    var paragraphStyle: LFParagraphStyle { get set }
    var scale: CGSize { get set }

    func setFontName(_ newName: String)
}
