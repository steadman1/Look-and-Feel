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
    var fontFamily: String { get }
    var fontMember: String { get }
    var fontSize: CGFloat { get }
    var leading: CGFloat { get }
    var tracking: CGFloat { get }
    var typeStyle: LFTypeStyle { get }
    var paragraphStyle: LFParagraphStyle { get }
    var scale: CGSize { get set }

    func setFont(_ familyName: String, with memberName: String)
    func setFontSize(_ fontSize: CGFloat)
    func setLeading(_ leading: CGFloat)
    func setTracking(_ tracking: CGFloat)
}
