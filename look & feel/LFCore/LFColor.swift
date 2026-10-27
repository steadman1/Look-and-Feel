//
//  LFColor.swift
//  look & feel
//

import Foundation

/// A platform-agnostic, `Codable` color (RGBA, components in `0...1`).
///
/// This is the source-of-truth color type for the document model. It lives in
/// `LFCore` (pure logic) so the model stays serializable and diffable without
/// any AppKit/SwiftUI dependency. UI layers bridge to `NSColor` / SwiftUI
/// `Color` — see `LFColor+AppKit`.
struct LFColor: Codable, Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    // MARK: - Common colors (mirror the `NSColor` statics used across the app)

    static let clear  = LFColor(red: 0, green: 0, blue: 0, alpha: 0)
    static let white  = LFColor(red: 1, green: 1, blue: 1)
    static let black  = LFColor(red: 0, green: 0, blue: 0)
    static let red    = LFColor(red: 1, green: 0, blue: 0)
    static let green  = LFColor(red: 0, green: 1, blue: 0)
    static let blue   = LFColor(red: 0, green: 0, blue: 1)
    static let orange = LFColor(red: 1, green: 0.5, blue: 0)
    static let gray   = LFColor(red: 0.5, green: 0.5, blue: 0.5)
}
