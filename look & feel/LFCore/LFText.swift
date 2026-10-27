//
//  LFText.swift
//  look & feel
//

import Foundation
import CoreGraphics

/// A text layer.
///
/// Converted from the old `LFLayer` subclass to a `Codable` value type. The
/// measured `size` is now *stored* (it was computed from an `NSAttributedString`
/// before, which required AppKit). The UI layer recomputes it whenever the text,
/// font, or scale changes — see `LFLayer+Rendering.recomputeSize()`.
struct LFText: Codable, Hashable {
    var base: LFBase

    var text: String

    /// Current rendered size. Recomputed by the UI from `text` + font + `scale`.
    var size: CGSize
    /// Text scale factor (applied as a transform when drawing).
    var scale: CGSize

    var reflection: [LFReflectionAxis]

    var fill: LFColor
    var stroke: LFColor
    var strokeWidth: CGFloat
    var strokePosition: LFStrokePosition

    var fontFamily: String
    var fontMember: String
    var fontSize: CGFloat
    var leading: CGFloat
    var tracking: CGFloat
    var typeStyle: LFTypeStyle
    var paragraphStyle: LFParagraphStyle

    init(
        id: UUID = UUID(),
        text: String,
        name: String,
        position: CGPoint = .zero,
        rotation: CGFloat = 0,
        reflection: [LFReflectionAxis] = [],
        fill: LFColor,
        stroke: LFColor,
        strokeWidth: CGFloat,
        strokePosition: LFStrokePosition,
        fontFamily: String,
        fontMember: String = "",
        fontSize: CGFloat,
        leading: CGFloat,
        tracking: CGFloat,
        typeStyle: LFTypeStyle,
        paragraphStyle: LFParagraphStyle
    ) {
        self.base = LFBase(id: id, name: name, position: position, rotation: rotation)
        self.text = text
        // `size` starts at zero; the UI recomputes it on first render.
        self.size = .zero
        self.scale = CGSize(width: 1, height: 1)
        self.reflection = reflection
        self.fill = fill
        self.stroke = stroke
        self.strokeWidth = strokeWidth
        self.strokePosition = strokePosition
        self.fontFamily = fontFamily
        self.fontMember = fontMember
        self.fontSize = fontSize
        self.leading = leading
        self.tracking = tracking
        self.typeStyle = typeStyle
        self.paragraphStyle = paragraphStyle
    }

    // MARK: - Transform helpers (mirror the old `Transformable` / `Resizable`)

    mutating func setPosition(_ position: CGPoint) {
        self.base.position = position
    }

    mutating func setRotation(_ rotation: CGFloat) {
        self.base.rotation = rotation
    }

    /// Set the rendered size and derive a matching uniform-ish scale.
    mutating func setSize(_ newSize: CGSize) {
        guard self.size.width > 0, self.size.height > 0 else {
            // No measured size yet; just record the target.
            self.size = newSize
            return
        }
        self.scale = CGSize(
            width: newSize.width / self.size.width,
            height: newSize.height / self.size.height
        )
        self.size = newSize
    }

    mutating func reflect(_ axis: LFReflectionAxis) {
        if let index = self.reflection.firstIndex(of: axis) {
            self.reflection.remove(at: index)
        } else {
            self.reflection.append(axis)
        }
    }

    // MARK: - Typography setters (mirror the old `Typographic`)

    mutating func setFont(_ familyName: String, with memberName: String) {
        self.fontFamily = familyName
        self.fontMember = memberName
    }

    mutating func setFontSize(_ fontSize: CGFloat) {
        self.fontSize = fontSize
    }

    mutating func setLeading(_ leading: CGFloat) {
        self.leading = leading
    }

    mutating func setTracking(_ tracking: CGFloat) {
        self.tracking = tracking
    }
}
