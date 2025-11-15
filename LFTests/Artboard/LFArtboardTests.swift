//
//  LFArtboardTests.swift
//  LFTests
//
//  Created by Spencer Steadman on 11/15/25.
//

import Testing
@testable import look___feel
internal import CoreGraphics

struct LFArtboardTests {

    @Test(
        "tests handleTransformRequests that takes translation requests",
        arguments: [
            CGPoint(x: -100, y: -100),
            CGPoint(x: 0, y: 0),
            CGPoint(x: 100, y: 0),
            CGPoint(x: 0, y: 100),
            CGPoint(x: 100, y: 100)
        ]
    )
    func testHandleTransformRequests_Translate(translation: CGPoint) async throws {
        let viewModel = ArtboardViewModel()
        viewModel.panOffset = translation

        let canvasView = await CanvasView(frame: .zero, viewModel: viewModel)
        let result = await canvasView.handleTransformRequests(for: [.translate])

        #expect(result.translation == translation)

        // expect defaults values back
        #expect(result.rotation == .zero)
        #expect(result.zoom == 1)
    }

    @Test("artboard rotation not implemented yet")
    func testHandleTransformRequests_Rotate() async throws {
        let viewModel = ArtboardViewModel()
        //        viewModel.rotation = 90
        let canvasView = await CanvasView(frame: .zero, viewModel: viewModel)
        let result = await canvasView.handleTransformRequests(for: [.rotate])

        #expect(result.rotation == .zero)

        // expect defaults values back
        #expect(result.translation == .zero)
        #expect(result.zoom == 1)
    }

    @Test(
        "tests handleTransformRequests that takes zoom requests",
        arguments: [0, 1, 5, 100]
    )
    func testHandleTransformRequests_Zoom(zoom: CGFloat) async throws {
        let viewModel = ArtboardViewModel()
        viewModel.zoom = zoom
        let canvasView = await CanvasView(frame: .zero, viewModel: viewModel)
        let result = await canvasView.handleTransformRequests(for: [.zoom])

        #expect(result.zoom == zoom)

        // expect defaults values back
        #expect(result.translation == .zero)
        #expect(result.rotation == .zero)
    }

    @Test(
        "tests handleTransformRequests that takes translation requests",
        arguments: [
            ( CGPoint(x: -100, y: -100), 0, 0.1 ),
            ( CGPoint(x: 0, y: 0), 0, 1 ),
            ( CGPoint(x: 100, y: 100), 0, 100 )
        ]
    )
    func testHandleTransformRequests_WithAllCases(
        translation: CGPoint,
        rotation: CGFloat,
        zoom: CGFloat
    ) async throws {
        let viewModel = ArtboardViewModel()
        viewModel.panOffset = translation
        viewModel.zoom = zoom

        let canvasView = await CanvasView(frame: .zero, viewModel: viewModel)
        let result = await canvasView.handleTransformRequests(for: LFCanvasTransformRequest.allCases)

        #expect(result.translation == translation)
        #expect(result.zoom == zoom)

        // not implemented
        #expect(result.rotation == .zero)
    }

    @Test("tests handleTransformRequests that takes no requests. should return default values")
    func testHandleTransformRequests_WithoutRequests() async throws {
        let canvasView = await CanvasView(frame: .zero, viewModel: .init())
        let result = await canvasView.handleTransformRequests(for: [])

        // expect defaults values back
        #expect(result.rotation == .zero)
        #expect(result.translation == .zero)
        #expect(result.zoom == 1)
    }



}
