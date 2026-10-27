//
//  LFUITests.swift
//  LFUITests
//
//  Created by Spencer Steadman on 11/25/25.
//

import XCTest

final class ArtboardScreenUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("--ui-test")
        app.launchArguments.append("--sandbox-viewModel")
        app.launch()
    }

    @MainActor
    func testPanelsExist() throws {
        // the Artboard's layers and design panels should exist on launch
        let app = XCUIApplication()
        let layersPanel = app.scrollViews["ArtboardScreenLayersPanel"]
        let designPanel = app.scrollViews["ArtboardScreenDesignPanel"]

        XCTAssertTrue(layersPanel.exists)
        XCTAssertTrue(designPanel.exists)
    }

    @MainActor
    func testButtonsExist() throws {
        // the Artboard's layers and design panels should exist on launch
        let app = XCUIApplication()
        let layerPreview = app.collectionViews["ArtboardScreenLayerPreviewStack"]

        XCTAssertTrue(layerPreview.exists)
    }
}
