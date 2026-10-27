//
//  UTType+LF.swift
//  look & feel
//

import UniformTypeIdentifiers

extension UTType {
    /// A Look & Feel document — a `.lffile` bundle containing `document.json`
    /// and an `assets/` folder.
    ///
    /// Declared in the app's `Info.plist` under `UTExportedTypeDeclarations`.
    static let lfDocument = UTType(exportedAs: "com.spencersteadman.look-and-feel.document")
}
