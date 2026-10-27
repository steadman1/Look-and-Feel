//
//  PersistenceTests.swift
//  LFTests
//
//  Created by Spencer Steadman on 10/26/26.
//

import Testing
@testable import look___feel
internal import Foundation

/// Round-trip and migration tests for the `.lffile` bundle format.
///
/// These exercise the pure `FileWrapper`-based I/O (`makeFileWrapper` /
/// `fromFileWrapper`) directly, so they run in the headless CLI test runner —
/// no AppKit, no window server required.
struct PersistenceTests {

    // MARK: - Bundle I/O helpers

    /// A throwaway `.lffile` bundle path in the temp directory.
    private func tempBundleURL() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("lf-test-\(UUID().uuidString).lffile")
    }

    /// Write a file's bundle to disk.
    private func writeBundle(_ file: LFDocumentFile, to url: URL) throws {
        try file.makeFileWrapper()
            .write(to: url, options: [.atomic], originalContentsURL: nil)
    }

    /// Read a bundle back from disk.
    private func readBundle(at url: URL) throws -> LFDocumentFile {
        let wrapper = try FileWrapper(url: url, options: [])
        return try LFDocumentFile.fromFileWrapper(wrapper)
    }

    // MARK: - Bundle round-trip

    @Test("a document survives a write/read round-trip")
    func bundleRoundTrip() throws {
        let original = LFDocument.preview
        let file = LFDocumentFile(document: original)

        let url = tempBundleURL()
        try writeBundle(file, to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        // The bundle must be a directory with document.json and assets/.
        let readWrapper = try FileWrapper(url: url, options: [])
        #expect(readWrapper.fileWrappers?["document.json"] != nil, "missing document.json")
        #expect(readWrapper.fileWrappers?["assets"] != nil, "missing assets/")

        let loaded = try readBundle(at: url)
        #expect(loaded.document == original, "document did not round-trip")
    }

    @Test("the on-disk document.json is valid, pretty-printed JSON")
    func documentJSONIsValid() throws {
        let file = LFDocumentFile(document: LFDocument.preview)
        let wrapper = try file.makeFileWrapper()

        guard let docData = wrapper.fileWrappers?["document.json"]?.regularFileContents else {
            Issue.record("document.json missing from bundle")
            return
        }

        // Pretty-printed (multi-line) and decodable.
        let json = String(data: docData, encoding: .utf8) ?? ""
        #expect(json.contains("\n"), "expected pretty-printed (multi-line) JSON")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(LFFile.self, from: docData)
        #expect(decoded.document == file.document)
    }

    // MARK: - Asset storage

    @Test("binary assets round-trip through the assets/ folder")
    func assetStorage() throws {
        var file = LFDocumentFile(document: LFDocument.preview)
        let pngSignature = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        file.assets["hero.png"] = pngSignature

        let url = tempBundleURL()
        try writeBundle(file, to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let loaded = try readBundle(at: url)
        #expect(loaded.assets["hero.png"] == pngSignature, "asset data did not round-trip")
    }

    @Test("a bundle with no assets loads with an empty asset table")
    func emptyAssets() throws {
        let file = LFDocumentFile(document: LFDocument.preview)
        let url = tempBundleURL()
        try writeBundle(file, to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let loaded = try readBundle(at: url)
        #expect(loaded.assets.isEmpty)
    }

    // MARK: - Envelope metadata

    @Test("the envelope stamps the current format and app versions")
    func envelopeMetadata() {
        let file = LFDocumentFile(document: LFDocument.preview)
        #expect(file.file.formatVersion == LFFile.currentFormatVersion)
        #expect(!file.file.appVersion.isEmpty)
        #expect(file.file.createdAt <= file.file.modifiedAt)
    }

    // MARK: - Migration

    @Test("a file at the current format version loads without migration")
    func migrationNoOp() throws {
        let file = LFFile(document: LFDocument.preview)
        #expect(file.formatVersion == LFFile.currentFormatVersion)

        let migrated = try LFFile.migrating(file)
        #expect(migrated == file, "current-version file should be unchanged")
    }

    @Test("a file from a newer version is rejected")
    func migrationRejectsNewer() {
        var future = LFFile(document: LFDocument.preview)
        future.formatVersion = LFFile.currentFormatVersion + 1

        #expect(throws: (any Error).self) {
            try LFFile.migrating(future)
        }
    }

    // MARK: - Snapshot (autosave detection)

    @Test("the snapshot is the design, so timestamps never mark it modified")
    func snapshotIsDesign() throws {
        var file = LFDocumentFile(document: LFDocument.preview)
        let snapshot = try file.snapshot(contentType: .lfDocument)
        #expect(snapshot == file.document)
    }

    @Test("a missing document.json surfaces a typed error")
    func missingDocumentError() {
        let empty = FileWrapper(directoryWithFileWrappers: [:])
        #expect(throws: LFPersistenceError.self) {
            _ = try LFDocumentFile.fromFileWrapper(empty)
        }
    }
}
