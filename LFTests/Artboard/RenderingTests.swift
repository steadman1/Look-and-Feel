//
//  RenderingTests.swift
//  LFTests
//
//  Smoke tests for the `LFLayer+Rendering` bridge — the AppKit/SwiftUI drawing
//  layer that sits on top of the pure `LFCore` value model. These confirm the
//  bridge actually produces real geometry (non-zero sizes) and draws without
//  crashing, which is the main risk when moving from class-based to value layers.
//
//  NOTE: these tests touch AppKit (NSFont, NSColor, CGContext). Run them via
//  Xcode's test runner, which provides a proper graphics environment. The bare
//  `xcrun xctest` CLI runner has no window server and can hit memory issues
//  (bus errors) after several AppKit-heavy tests — an environment artifact,
//  not a code defect (the app itself runs cleanly).
//

import Testing
@testable import look___feel
internal import CoreGraphics

struct RenderingTests {

    private func testPath() -> LFLayer {
        LFLayer(
            LFPath(
                name: "Test Path",
                position: .zero,
                size: .zero,
                fill: .red,
                stroke: .blue,
                strokeWidth: 2,
                strokePosition: .center,
                points: [
                    LFBezierPoint(cornerStyle: .corner, anchor: CGPoint(x: 0, y: 0), handle1: .zero, handle2: .zero),
                    LFBezierPoint(cornerStyle: .corner, anchor: CGPoint(x: 100, y: 0), handle1: .zero, handle2: .zero),
                    LFBezierPoint(cornerStyle: .corner, anchor: CGPoint(x: 100, y: 60), handle1: .zero, handle2: .zero),
                    LFBezierPoint(cornerStyle: .corner, anchor: CGPoint(x: 0, y: 60), handle1: .zero, handle2: .zero)
                ],
                isClosed: true
            )
        )
    }

    private func testText() -> LFLayer {
        LFLayer(
            LFText(
                text: "Hello World",
                name: "Test Text",
                position: .zero,
                fill: .black,
                stroke: .clear,
                strokeWidth: 0,
                strokePosition: .center,
                fontFamily: "Helvetica",
                fontSize: 24,
                leading: 0,
                tracking: 0,
                typeStyle: .point,
                paragraphStyle: .left
            )
        )
    }

    @Test("recomputing a path's size from its points yields a non-zero frame")
    func testPathRecomputeSize() {
        var layer = testPath()
        layer.recomputeSize()
        #expect(layer.size.width > 0, "path width should be non-zero, got \(layer.size.width)")
        #expect(layer.size.height > 0, "path height should be non-zero, got \(layer.size.height)")
    }

    @Test("recomputing a text layer's size yields a non-zero frame")
    func testTextRecomputeSize() {
        var layer = testText()
        layer.recomputeSize()
        #expect(layer.size.width > 0, "text width should be non-zero, got \(layer.size.width)")
        #expect(layer.size.height > 0, "text height should be non-zero, got \(layer.size.height)")
    }

    @Test("drawing a path into a bitmap context does not crash")
    func testDrawPathIntoBitmap() {
        let layer = testPath()

        let width = 200, height = 200
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        ) else {
            Issue.record("Could not create bitmap context")
            return
        }

        // Must not throw or crash.
        layer.draw(in: context)
    }

    @Test("drawing a text layer into a bitmap context does not crash")
    func testDrawTextIntoBitmap() {
        let layer = testText()

        let width = 300, height = 100
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        ) else {
            Issue.record("Could not create bitmap context")
            return
        }

        layer.draw(in: context)
    }

    @Test("each layer kind exposes a non-empty symbol name")
    func testSymbolName() {
        #expect(!testPath().symbolName.isEmpty, "path symbolName should be non-empty")
        #expect(!testText().symbolName.isEmpty, "text symbolName should be non-empty")
        let group = LFLayer(LFGroup(name: "Test Group", children: [testPath()]))
        #expect(!group.symbolName.isEmpty, "group symbolName should be non-empty")
    }
}
