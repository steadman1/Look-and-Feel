//
//  LFFile.swift
//  look & feel
//

import Foundation

/// The on-disk **file envelope** — wraps the pure design (`LFDocument`) with
/// persistence metadata (format version, app version, timestamps).
///
/// This is the top-level type serialized to `document.json` inside a `.lffile`
/// bundle. The design itself (`LFDocument`) stays clean for the Semantic and
/// Edit Tree canvases; only the persistence layer touches `LFFile`.
///
/// The separation matters:
/// - **Edit Tree** (Phase 2) commits `LFDocument` snapshots — not the envelope.
/// - **Semantic** (Phase 3) serializes `LFDocument` to code — not the envelope.
/// - **Persistence** (this phase) reads/writes `LFFile`.
struct LFFile: Codable, Equatable {

    /// The current schema version written by this build of Look & Feel.
    static let currentFormatVersion = 1

    /// The schema version of *this* file. Bumped when the format changes; drives
    /// migrations on load (see `LFFile+Migration`).
    var formatVersion: Int

    /// The Look & Feel app version that last wrote this file.
    var appVersion: String

    var createdAt: Date
    var modifiedAt: Date

    /// The pure design — the single source of truth for all three canvases.
    var document: LFDocument

    init(
        formatVersion: Int = LFFile.currentFormatVersion,
        appVersion: String = Self.currentAppVersion,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        document: LFDocument
    ) {
        self.formatVersion = formatVersion
        self.appVersion = appVersion
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.document = document
    }

    /// The marketing version of the running app (e.g. "0.1.0"), read from the
    /// bundle's `CFBundleShortVersionString`.
    static var currentAppVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? "0.0.0"
    }
}
