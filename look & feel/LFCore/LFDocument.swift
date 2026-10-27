//
//  LFDocument.swift
//  look & feel
//

import Foundation
import CoreGraphics

/// The root document model — the **single source of truth** for all three
/// canvases (Artboard, Semantic, Edit Tree).
///
/// Everything in Look & Feel is a projection of one `LFDocument`:
/// - **Artboard** renders it visually.
/// - **Semantic** edits it as code.
/// - **Edit Tree** versions it (snapshots are cheap copies of this value).
///
/// It is a `Codable` value type, so persistence and versioning fall out for
/// free. The live editing state wraps an instance of this in an observable
/// container — see `ArtboardViewModel`.
struct LFDocument: Codable, Hashable {
    /// The document's title (becomes the file name on first save).
    var name: String

    /// The intended canvas / artboard size in document points.
    var canvasSize: CGSize

    /// The design content, in back-to-front draw order.
    var layers: [LFLayer]

    init(
        name: String = "Untitled",
        canvasSize: CGSize = .init(width: 960, height: 690),
        layers: [LFLayer] = []
    ) {
        self.name = name
        self.canvasSize = canvasSize
        self.layers = layers
    }
}

extension LFDocument {
    /// Sample content used by SwiftUI previews and the UI-test sandbox.
    static var preview: LFDocument {
        LFDocument(
            name: "Preview",
            layers: [
                LFLayer(LFPath(name: "Shape 1", position: .zero, size: .init(width: 100, height: 100), fill: .white, stroke: .clear, strokeWidth: 0, strokePosition: .center, points: [], isClosed: false)),
                LFLayer(LFPath(name: "Shape 2", position: .init(x: 100, y: 100), size: .init(width: 100, height: 100), fill: .blue, stroke: .clear, strokeWidth: 0, strokePosition: .center, points: [], isClosed: false)),

                LFLayer(LFPath(name: "Shape 3", position: .init(x: 0, y: 300), size: .init(width: 50, height: 50), fill: .white, stroke: .clear, strokeWidth: 0, strokePosition: .center, points: [], isClosed: false)),
                LFLayer(LFPath(name: "Shape 4", position: .init(x: 50, y: 350), size: .init(width: 100, height: 50), fill: .blue, stroke: .clear, strokeWidth: 0, strokePosition: .center, points: [], isClosed: false)),

                LFLayer(LFText(text: "Testing\nText", name: "Text 1", position: .init(x: 200, y: 200), fill: .red, stroke: .clear, strokeWidth: 0, strokePosition: .center, fontFamily: "helvetica", fontSize: 40, leading: 0, tracking: 0, typeStyle: .point, paragraphStyle: .center))
            ]
        )
    }
}
