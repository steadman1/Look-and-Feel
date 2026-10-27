//
//  LFLayer.swift
//  look & feel
//

import Foundation
import CoreGraphics

/// The unified, `Codable` layer type. A document's layers are `[LFLayer]`.
///
/// This is the keystone of Look & Feel: **one value type, projected by all three
/// canvases** (Artboard, Semantic, Edit Tree). Because it is a value type, a
/// snapshot is a cheap copy — which makes versioning (Edit Tree) and
/// serialization (persistence) trivial.
///
/// The enum exposes settable computed properties for every capability so that
/// SwiftUI `Binding<LFLayer>` + dynamic member lookup (`.position.x`, `.name`,
/// `.size`, …) keeps working exactly as it did with the old class hierarchy.
enum LFLayer: Codable, Hashable, Identifiable, Transformable, Resizable, Colorable, Traceable, Typographic {

    case path(LFPath)
    case text(LFText)
    case group(LFGroup)

    // MARK: - Identity

    var id: UUID {
        switch self {
        case .path(let p): return p.base.id
        case .text(let t): return t.base.id
        case .group(let g): return g.base.id
        }
    }

    // MARK: - Transformable (all layers)

    var name: String {
        get {
            switch self {
            case .path(let p): return p.base.name
            case .text(let t): return t.base.name
            case .group(let g): return g.base.name
            }
        }
        set {
            switch self {
            case .path(var p): p.base.name = newValue; self = .path(p)
            case .text(var t): t.base.name = newValue; self = .text(t)
            case .group(var g): g.base.name = newValue; self = .group(g)
            }
        }
    }

    var position: CGPoint {
        get {
            switch self {
            case .path(let p): return p.base.position
            case .text(let t): return t.base.position
            case .group(let g): return g.base.position
            }
        }
        set {
            switch self {
            case .path(var p): p.base.position = newValue; self = .path(p)
            case .text(var t): t.base.position = newValue; self = .text(t)
            case .group(var g): g.setPosition(newValue); self = .group(g)
            }
        }
    }

    var rotation: CGFloat {
        get {
            switch self {
            case .path(let p): return p.base.rotation
            case .text(let t): return t.base.rotation
            case .group(let g): return g.base.rotation
            }
        }
        set {
            switch self {
            case .path(var p): p.setRotation(newValue); self = .path(p)
            case .text(var t): t.setRotation(newValue); self = .text(t)
            case .group(var g): g.setRotation(newValue); self = .group(g)
            }
        }
    }

    // MARK: - Resizable (path & text directly; group via bounding box)

    var size: CGSize {
        get {
            switch self {
            case .path(let p): return p.size
            case .text(let t): return t.size
            case .group(let g): return g.boundingBox.size
            }
        }
        set {
            switch self {
            case .path(var p): p.setSize(newValue); self = .path(p)
            case .text(var t): t.setSize(newValue); self = .text(t)
            case .group(var g): g.resize(to: newValue); self = .group(g)
            }
        }
    }

    var frame: CGRect {
        CGRect(origin: position, size: size)
    }

    var reflection: [LFReflectionAxis] {
        get {
            switch self {
            case .path(let p): return p.reflection
            case .text(let t): return t.reflection
            case .group: return []
            }
        }
        set {
            switch self {
            case .path(var p): p.reflection = newValue; self = .path(p)
            case .text(var t): t.reflection = newValue; self = .text(t)
            case .group: break
            }
        }
    }

    // MARK: - Colorable (path & text; group has no direct fill/stroke)

    var fill: LFColor {
        get {
            switch self {
            case .path(let p): return p.fill
            case .text(let t): return t.fill
            case .group: return .clear
            }
        }
        set {
            switch self {
            case .path(var p): p.fill = newValue; self = .path(p)
            case .text(var t): t.fill = newValue; self = .text(t)
            case .group: break
            }
        }
    }

    var stroke: LFColor {
        get {
            switch self {
            case .path(let p): return p.stroke
            case .text(let t): return t.stroke
            case .group: return .clear
            }
        }
        set {
            switch self {
            case .path(var p): p.stroke = newValue; self = .path(p)
            case .text(var t): t.stroke = newValue; self = .text(t)
            case .group: break
            }
        }
    }

    var strokeWidth: CGFloat {
        get {
            switch self {
            case .path(let p): return p.strokeWidth
            case .text(let t): return t.strokeWidth
            case .group: return 0
            }
        }
        set {
            switch self {
            case .path(var p): p.strokeWidth = newValue; self = .path(p)
            case .text(var t): t.strokeWidth = newValue; self = .text(t)
            case .group: break
            }
        }
    }

    var strokePosition: LFStrokePosition {
        get {
            switch self {
            case .path(let p): return p.strokePosition
            case .text(let t): return t.strokePosition
            case .group: return .center
            }
        }
        set {
            switch self {
            case .path(var p): p.strokePosition = newValue; self = .path(p)
            case .text(var t): t.strokePosition = newValue; self = .text(t)
            case .group: break
            }
        }
    }

    // MARK: - Traceable (path only)

    var points: [LFBezierPoint] {
        get {
            switch self {
            case .path(let p): return p.points
            default: return []
            }
        }
        set {
            switch self {
            case .path(var p): p.points = newValue; self = .path(p)
            default: break
            }
        }
    }

    var isClosed: Bool {
        get {
            switch self {
            case .path(let p): return p.isClosed
            default: return false
            }
        }
        set {
            switch self {
            case .path(var p): p.isClosed = newValue; self = .path(p)
            default: break
            }
        }
    }

    // MARK: - Typographic (text only; safe defaults otherwise)

    var text: String {
        get {
            switch self {
            case .text(let t): return t.text
            default: return ""
            }
        }
        set {
            switch self {
            case .text(var t): t.text = newValue; self = .text(t)
            default: break
            }
        }
    }

    var fontFamily: String {
        get {
            switch self {
            case .text(let t): return t.fontFamily
            default: return ""
            }
        }
        set {
            switch self {
            case .text(var t): t.fontFamily = newValue; self = .text(t)
            default: break
            }
        }
    }

    var fontMember: String {
        get {
            switch self {
            case .text(let t): return t.fontMember
            default: return ""
            }
        }
        set {
            switch self {
            case .text(var t): t.fontMember = newValue; self = .text(t)
            default: break
            }
        }
    }

    var fontSize: CGFloat {
        get {
            switch self {
            case .text(let t): return t.fontSize
            default: return 0
            }
        }
        set {
            switch self {
            case .text(var t): t.setFontSize(newValue); self = .text(t)
            default: break
            }
        }
    }

    var leading: CGFloat {
        get {
            switch self {
            case .text(let t): return t.leading
            default: return 0
            }
        }
        set {
            switch self {
            case .text(var t): t.setLeading(newValue); self = .text(t)
            default: break
            }
        }
    }

    var tracking: CGFloat {
        get {
            switch self {
            case .text(let t): return t.tracking
            default: return 0
            }
        }
        set {
            switch self {
            case .text(var t): t.setTracking(newValue); self = .text(t)
            default: break
            }
        }
    }

    var typeStyle: LFTypeStyle {
        get {
            switch self {
            case .text(let t): return t.typeStyle
            default: return .point
            }
        }
        set {
            switch self {
            case .text(var t): t.typeStyle = newValue; self = .text(t)
            default: break
            }
        }
    }

    var paragraphStyle: LFParagraphStyle {
        get {
            switch self {
            case .text(let t): return t.paragraphStyle
            default: return .left
            }
        }
        set {
            switch self {
            case .text(var t): t.paragraphStyle = newValue; self = .text(t)
            default: break
            }
        }
    }

    var scale: CGSize {
        get {
            switch self {
            case .text(let t): return t.scale
            default: return CGSize(width: 1, height: 1)
            }
        }
        set {
            switch self {
            case .text(var t): t.scale = newValue; self = .text(t)
            default: break
            }
        }
    }

    // MARK: - Dispatching methods (mirror the old protocol requirements)

    mutating func setPosition(_ position: CGPoint) {
        switch self {
        case .path(var p): p.setPosition(position); self = .path(p)
        case .text(var t): t.setPosition(position); self = .text(t)
        case .group(var g): g.setPosition(position); self = .group(g)
        }
    }

    mutating func setRotation(_ rotation: CGFloat) {
        switch self {
        case .path(var p): p.setRotation(rotation); self = .path(p)
        case .text(var t): t.setRotation(rotation); self = .text(t)
        case .group(var g): g.setRotation(rotation); self = .group(g)
        }
    }

    mutating func setSize(_ size: CGSize) {
        self.size = size
    }

    mutating func setFont(_ familyName: String, with memberName: String) {
        switch self {
        case .text(var t): t.setFont(familyName, with: memberName); self = .text(t)
        default: break
        }
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

    mutating func reflect(_ axis: LFReflectionAxis) {
        switch self {
        case .path(var p): p.reflect(axis); self = .path(p)
        case .text(var t): t.reflect(axis); self = .text(t)
        case .group: break
        }
    }

    // MARK: - Capability queries (replace the old `as? Resizable` / `is P` checks)

    /// Whether this layer exposes width/height controls (path & text; not group).
    var isResizable: Bool {
        switch self {
        case .path, .text: return true
        case .group: return false
        }
    }

    /// Whether this layer exposes typography controls (text only).
    var isTypographic: Bool {
        if case .text = self { return true }
        return false
    }

    /// Whether this layer exposes a bezier trace (path only).
    var isTraceable: Bool {
        if case .path = self { return true }
        return false
    }

    // MARK: - Presentation

    /// SF Symbol name for the layer's icon (bridged to `Image` in the UI layer).
    var symbolName: String {
        switch self {
        case .path: return "rectangle.portrait"
        case .text: return "textformat"
        case .group: return "rectangle.portrait"
        }
    }

    // MARK: - Kind

    enum Kind: String, Codable, Hashable {
        case path, text, group
    }

    var kind: Kind {
        switch self {
        case .path: return .path
        case .text: return .text
        case .group: return .group
        }
    }

    // MARK: - Convenience initializers

    init(_ path: LFPath) { self = .path(path) }
    init(_ text: LFText) { self = .text(text) }
    init(_ group: LFGroup) { self = .group(group) }
}
