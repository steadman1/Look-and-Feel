//
//  LFLayer+Rendering.swift
//  look & feel
//

import AppKit
import SwiftUI

/// The seam where the pure `LFCore` model meets AppKit/SwiftUI rendering.
///
/// `LFLayer` is a value type with no drawing code (it lives in `LFCore`). This
/// extension provides the AppKit `draw(in:)`, the SwiftUI `symbol`, and text
/// size measurement. It replicates the drawing behavior of the old class
/// hierarchy exactly.
extension LFLayer {

    // MARK: - Drawing

    func draw(in context: CGContext) {
        switch self {
        case .path(let p):  drawPath(p, in: context)
        case .text(let t):  drawText(t, in: context)
        case .group(let g): g.children.forEach { $0.draw(in: context) }
        }
    }

    private func drawPath(_ p: LFPath, in context: CGContext) {
        let frame = CGRect(origin: p.base.position, size: p.size)
        let path = NSBezierPath(rect: frame)

        if p.fill != .clear {
            p.fill.nsColor.setFill()
            path.fill()
        }

        if p.strokeWidth > 0 && p.stroke != .clear {
            p.stroke.nsColor.setStroke()
            path.lineWidth = p.strokeWidth
            path.stroke()
        }
    }

    private func drawText(_ t: LFText, in context: CGContext) {
        let attributed = Self.attributedString(for: t)

        context.saveGState()
        context.translateBy(x: t.base.position.x + t.size.width / 2,
                            y: t.base.position.y + t.size.height / 2)
        context.rotate(by: t.base.rotation * .pi / 180.0)
        context.translateBy(x: -t.size.width / 2, y: -t.size.height / 2)

        switch t.typeStyle {
        case .point:
            context.scaleBy(x: t.scale.width, y: t.scale.height)
            attributed.draw(at: .zero)
        case .paragraph:
            attributed.draw(in: CGRect(origin: .zero, size: t.size))
        }

        context.restoreGState()
    }

    // MARK: - Symbol (SwiftUI)

    var symbol: AnyView {
        switch self {
        case .text:
            return AnyView(Image(systemName: "textformat").fontWeight(.semibold))
        default:
            return AnyView(Image(systemName: symbolName))
        }
    }

    // MARK: - Text measurement

    /// Rebuild the stored `size` so it stays consistent with the layer's content.
    ///
    /// The pure `LFCore` model can't measure anything (no AppKit), so this lives
    /// in the rendering seam:
    ///  - **Text** — measures the attributed string (scaled by `scale`).
    ///  - **Path** — derives the bounding box from the bezier points. Paths with
    ///    no points (placeholder rects) keep their explicit `size` untouched.
    ///
    /// Called by the UI whenever a layer's content changes (text edited, points
    /// moved) so the stored `size` — used for hit-testing and layout — stays in
    /// sync with what is actually drawn.
    mutating func recomputeSize() {
        switch self {
        case .text(var t):
            let natural = Self.attributedString(for: t).size()
            t.size = CGSize(
                width: natural.width * t.scale.width,
                height: natural.height * t.scale.height
            )
            self = .text(t)

        case .path(var p) where !p.points.isEmpty:
            p.size = Self.bezierPath(for: p).bounds.size
            self = .path(p)

        default:
            // Groups and empty (placeholder) paths keep their explicit size.
            break
        }
    }

    /// Build an `NSBezierPath` from a path layer's control points, connecting
    /// each point to the next in sequence (and closing the loop if `isClosed`).
    ///
    /// Point anchors are in the layer's local coordinate space (relative to
    /// `base.position`). Used for size measurement; the canvas uses the same
    /// construction when it renders real vector geometry.
    private static func bezierPath(for p: LFPath) -> NSBezierPath {
        let path = NSBezierPath()
        guard let first = p.points.first else { return path }
        path.move(to: first.anchor)

        for index in 1..<p.points.count {
            let previous = p.points[index - 1]
            let current = p.points[index]
            path.curve(
                to: current.anchor,
                controlPoint1: previous.handle2,
                controlPoint2: current.handle1
            )
        }

        if p.isClosed, p.points.count > 1 {
            let last = p.points[p.points.count - 1]
            path.curve(
                to: first.anchor,
                controlPoint1: last.handle2,
                controlPoint2: first.handle1
            )
            path.close()
        }

        return path
    }

    // MARK: - Attributed string construction (shared by draw + measure)

    private static func font(for t: LFText) -> NSFont {
        let name = t.fontMember.isEmpty ? t.fontFamily : t.fontMember
        return NSFont(name: name, size: t.fontSize) ?? .systemFont(ofSize: t.fontSize)
    }

    private static func attributedString(for t: LFText) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = t.leading
        paragraphStyle.alignment = NSTextAlignment.left

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: t.fill.nsColor,
            .strokeColor: t.stroke.nsColor,
            .strokeWidth: t.strokeWidth,
            .paragraphStyle: paragraphStyle,
            .tracking: t.tracking,
            .font: font(for: t)
        ]

        return NSAttributedString(string: t.text, attributes: attributes)
    }
}
