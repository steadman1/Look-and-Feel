//
//  Typographic.swift
//  look & feel
//

import CoreGraphics

/// How a text layer's size is determined.
enum LFTypeStyle: Int, Codable, Hashable, CaseIterable {
    case point, paragraph
}

/// A layer that carries typographic properties.
protocol Typographic {
    var fontFamily: String { get }
    var fontMember: String { get }
    var fontSize: CGFloat { get }
    var leading: CGFloat { get }
    var tracking: CGFloat { get }
    var typeStyle: LFTypeStyle { get }
    var paragraphStyle: LFParagraphStyle { get }
    var scale: CGSize { get set }

    mutating func setFont(_ familyName: String, with memberName: String)
    mutating func setFontSize(_ fontSize: CGFloat)
    mutating func setLeading(_ leading: CGFloat)
    mutating func setTracking(_ tracking: CGFloat)
}
