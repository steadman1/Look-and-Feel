//
//  LFDocumentFile.swift
//  look & feel
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

/// A `FileDocument` that reads and writes Look & Feel `.lffile` bundles.
///
/// The bundle is a directory with two members:
/// - `document.json` — the `LFFile` envelope (metadata + design), pretty-printed.
/// - `assets/` — a folder of binary assets (images), named by asset id.
///
/// `FileWrapper` natively represents a directory, so the bundle maps directly
/// onto it — no custom container parsing is required. This is what lets us use
/// SwiftUI's `DocumentGroup` for the native macOS open/save/recent/autosave UX.
///
/// The core read/write logic lives in `makeFileWrapper()` / `fromFileWrapper(_:)`
/// (pure `FileWrapper` operations) so it is unit-testable without SwiftUI's
/// non-constructible `ReadConfiguration` / `WriteConfiguration` types. The
/// `FileDocument` methods below are thin wrappers over those.
struct LFDocumentFile: FileDocument {

    static let readableContentTypes: [UTType] = [.lfDocument]

    /// The envelope (metadata + design).
    var file: LFFile

    /// Binary assets keyed by file name (e.g. `"hero.png"`). Empty until image
    /// layers exist (Phase 4); the `assets/` folder is in place now so the
    /// format is ready for them.
    var assets: [String: Data] = [:]

    /// Pass-through to the design, for ergonomic access (`file.document.layers`)
    /// without spelling out the envelope each time.
    var document: LFDocument {
        get { file.document }
        set { file.document = newValue }
    }

    // MARK: - FileDocument

    init(configuration: ReadConfiguration) throws {
        self = try LFDocumentFile.fromFileWrapper(configuration.file)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        try makeFileWrapper()
    }

    /// The lightweight, comparable representation the system uses to detect
    /// unsaved changes and drive autosave. This is the *design* (not the file
    /// metadata), so volatile timestamps never trigger false "modified" states.
    mutating func snapshot(contentType: UTType) throws -> LFDocument {
        document
    }

    // MARK: - Core I/O (testable)

    /// Encode this file into a directory `FileWrapper` — the `.lffile` bundle.
    /// Stamps a fresh `modifiedAt`, writes `document.json` (pretty-printed) and
    /// the `assets/` folder.
    func makeFileWrapper() throws -> FileWrapper {
        var outFile = file
        outFile.modifiedAt = Date()

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let docData: Data
        do {
            docData = try encoder.encode(outFile)
        } catch {
            throw LFPersistenceError.encodingFailed(underlying: error)
        }

        var assetChildren: [String: FileWrapper] = [:]
        for (name, data) in assets {
            assetChildren[name] = FileWrapper(regularFileWithContents: data)
        }
        let assetsWrapper = FileWrapper(directoryWithFileWrappers: assetChildren)

        let children: [String: FileWrapper] = [
            "document.json": FileWrapper(regularFileWithContents: docData),
            "assets": assetsWrapper
        ]

        return FileWrapper(directoryWithFileWrappers: children)
    }

    /// Decode a `.lffile` bundle from a directory `FileWrapper`. Reads
    /// `document.json`, migrates it to the current schema, and loads `assets/`.
    static func fromFileWrapper(_ wrapper: FileWrapper) throws -> LFDocumentFile {
        guard let docWrapper = wrapper.fileWrappers?["document.json"],
              let data = docWrapper.regularFileContents else {
            throw LFPersistenceError.missingDocument
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let decoded: LFFile
        do {
            decoded = try decoder.decode(LFFile.self, from: data)
        } catch {
            throw LFPersistenceError.decodingFailed(underlying: error)
        }

        var result = LFDocumentFile(file: try LFFile.migrating(decoded))

        if let assetsWrapper = wrapper.fileWrappers?["assets"] {
            var loaded: [String: Data] = [:]
            for (name, asset) in assetsWrapper.fileWrappers ?? [:] {
                if let data = asset.regularFileContents {
                    loaded[name] = data
                }
            }
            result.assets = loaded
        }

        return result
    }

    // MARK: - Convenience

    /// Build a file from an envelope (and optional assets). Used by the decoder.
    init(file: LFFile, assets: [String: Data] = [:]) {
        self.file = file
        self.assets = assets
    }

    /// A new, empty document. Used by `DocumentGroup(newDocument:)`.
    init() {
        self.file = LFFile(document: LFDocument())
    }

    /// A document wrapping an existing design.
    init(document: LFDocument) {
        self.file = LFFile(document: document)
    }
}
