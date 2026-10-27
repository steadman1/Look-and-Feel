//
//  LFColor+AppKit.swift
//  look & feel
//

import AppKit

/// Bridges the pure `LFColor` model type to AppKit's `NSColor` for drawing.
/// This is the seam where the platform-agnostic model meets the UI.
extension LFColor {
    /// The `NSColor` equivalent (converted to `sRGB` for consistent drawing).
    var nsColor: NSColor {
        NSColor(
            srgbRed: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(alpha)
        )
    }
}

extension NSColor {
    /// The pure `LFColor` equivalent, sampled in the `sRGB` color space.
    var lfColor: LFColor {
        let converted = usingColorSpace(.sRGB) ?? self
        return LFColor(
            red: Double(converted.redComponent),
            green: Double(converted.greenComponent),
            blue: Double(converted.blueComponent),
            alpha: Double(converted.alphaComponent)
        )
    }
}
