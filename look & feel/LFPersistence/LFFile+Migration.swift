//
//  LFFile+Migration.swift
//  look & feel
//

import Foundation

extension LFFile {

    /// Bring a decoded file up to the current schema version, running migrations
    /// in order.
    ///
    /// - Parameter file: A freshly decoded `LFFile` (at whatever version it was
    ///   saved with).
    /// - Returns: A file at `LFFile.currentFormatVersion`.
    /// - Throws: `LFPersistenceError.unsupportedFormatVersion` if the file is from
    ///   a *newer* version than this build understands, or `.migrationFailed` if
    ///   a migration step throws.
    static func migrating(_ file: LFFile) throws -> LFFile {
        // Reject files written by a newer version of the app.
        guard file.formatVersion <= LFFile.currentFormatVersion else {
            throw LFPersistenceError.unsupportedFormatVersion(file.formatVersion)
        }

        var current = file
        // Run one-version-at-a-time migrations until we reach the current schema.
        while current.formatVersion < LFFile.currentFormatVersion {
            let from = current.formatVersion
            do {
                current = try Self.migrateStep(current, from: from)
            } catch {
                throw LFPersistenceError.migrationFailed(from: from, to: from + 1, underlying: error)
            }
        }
        return current
    }

    /// Advance a file by exactly one schema version (`version` → `version + 1`).
    ///
    /// Add cases here as the format evolves. Each case transforms a file at the
    /// given version into the next one. The final `formatVersion = version + 1`
    /// guarantees forward progress, so the caller's loop always terminates.
    private static func migrateStep(_ file: LFFile, from version: Int) throws -> LFFile {
        var result = file
        switch version {
        // case 1: ... v1 → v2 transformation ...
        default:
            break
        }
        result.formatVersion = version + 1
        return result
    }
}
