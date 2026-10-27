//
//  LFBase.swift
//  look & feel
//

import Foundation
import CoreGraphics

/// Shared identity + transform state for every layer payload.
///
/// Factored out so `LFPath`, `LFText`, and `LFGroup` don't each re-declare
/// `id` / `name` / `position` / `rotation`. All layer types are transformable,
/// so these live on the base.
struct LFBase: Codable, Hashable {
    var id: UUID
    var name: String
    var position: CGPoint
    var rotation: CGFloat

    init(
        id: UUID = UUID(),
        name: String,
        position: CGPoint = .zero,
        rotation: CGFloat = 0
    ) {
        self.id = id
        self.name = name
        self.position = position
        self.rotation = rotation
    }
}
