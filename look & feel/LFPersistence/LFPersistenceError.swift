//
//  LFPersistenceError.swift
//  look & feel
//

import Foundation

/// Errors surfaced by the persistence layer when reading or writing `.lffile`
/// bundles. Conforms to `LocalizedError` so the messages can be shown directly
/// in user-facing alerts.
enum LFPersistenceError: LocalizedError {

    /// The bundle is missing its `document.json` member.
    case missingDocument

    /// The file's `formatVersion` is newer than the newest version this build
    /// knows how to migrate to.
    case unsupportedFormatVersion(Int)

    /// A migration step threw while bringing an older file up to the current
    /// schema.
    case migrationFailed(from: Int, to: Int, underlying: Error)

    /// Encoding the envelope to JSON failed.
    case encodingFailed(underlying: Error)

    /// Decoding `document.json` failed.
    case decodingFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .missingDocument:
            return "This Look & Feel file is missing its document data."
        case .unsupportedFormatVersion(let version):
            return "This file was saved by a newer version of Look & Feel (format \(version)). Please update the app to open it."
        case .migrationFailed(let from, let to, _):
            return "Look & Feel couldn't update this file from format \(from) to \(to)."
        case .encodingFailed:
            return "Look & Feel couldn't save this document."
        case .decodingFailed:
            return "This Look & Feel file could not be read."
        }
    }
}
