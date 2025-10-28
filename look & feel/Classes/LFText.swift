//
//  LFText.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import AppKit
import SwiftUI

class LFText: LFLayer, Resizable, Typographic, Colorable {

    @Published var text: String

    // MARK: Resizable conformance
    @Published var size: CGSize
    @Published var reflection: [LFReflectionAxis]

    // MARK: Typographic conformance
    @Published var fontName: String
    @Published var fontSize: Double
    @Published var leading: CGFloat
    @Published var letterSpacing: CGFloat
    @Published var typeStyle: LFTypeStyle
    @Published var paragraphStyle: LFParagraphStyle
    internal var scale: CGSize
    internal var attributedString: NSAttributedString
    let fontAttributes: [NSAttributedString.Key: Any]

    // MARK: Colorable conformance
    @Published var fill: NSColor
    @Published var stroke: NSColor
    @Published var strokeWidth: CGFloat
    @Published var strokePosition: LFStrokePosition
    
    init(
        text: String,
        name: String,
        position: CGPoint,
        rotation: CGFloat = 0,

        size: CGSize,
        reflection: [LFReflectionAxis] = [],
        
        fill: NSColor,
        stroke: NSColor,
        strokeWidth: CGFloat,
        strokePosition: LFStrokePosition,
        
        fontName: String,
        fontSize: Double,
        leading: CGFloat,
        letterSpacing: CGFloat,
        typeStyle: LFTypeStyle,
        paragraphStyle: LFParagraphStyle,
    ) {
        self.text = text

        self.size = size
        self.reflection = reflection

        self.fill = fill
        self.stroke = stroke
        self.strokeWidth = strokeWidth
        self.strokePosition = strokePosition
        
        self.fontName = fontName
        self.fontSize = fontSize
        self.leading = leading
        self.letterSpacing = letterSpacing
        self.typeStyle = typeStyle
        self.paragraphStyle = paragraphStyle
        self.scale = CGSize(width: 1, height: 1)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = leading
        paragraphStyle.alignment = NSTextAlignment.left
        self.fontAttributes = [
            .foregroundColor: fill,
            .strokeColor: stroke,
            .strokeWidth: strokeWidth,
            .paragraphStyle: paragraphStyle
        ]

        let nsFont = NSFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: fontSize)
        self.attributedString = NSAttributedString(
            string: text,
            attributes: fontAttributes.merging([.font: nsFont], uniquingKeysWith: { $1 })
        )

        super.init(
            name: name,
            position: position,
            rotation: rotation
        )

        self.setSize(attributedString.size())
    }

    var frame: CGRect {
        CGRect(
            origin: position,
            size: size
        )
    }

    func setAttributedString() {
        self.attributedString = NSAttributedString(
            string: text,
            attributes: fontAttributes.merging([.font: getFont(fontSize: fontSize)], uniquingKeysWith: { $1 })
        )
    }

    func setSize(_ newSize: CGSize) {
        switch typeStyle {
        case .point:
            let initialSize = attributedString.size()
            self.scale = CGSize(
                width: newSize.width / initialSize.width,
                height: newSize.height / initialSize.height
            )
        case .paragraph:
            break
        }
        self.size = newSize
    }

    private func reflect(_ axis: LFReflectionAxis) {
        if !reflection.contains(axis) {
            self.reflection.append(axis)
        } else {
            self.reflection.removeAll { $0 == .horizontal }
        }
    }

    func reflect(_ axes: [LFReflectionAxis]) {
        for axis in axes { reflect(axis) }
    }

    func setFontName(_ newName: String) {
        self.fontName = newName
        self.setAttributedString()

        // dont change scale
        self.size = attributedString.size()
    }

    override var symbol: AnyView {
        AnyView (
            Image(systemName: "textformat")
                .fontWeight(.semibold)
        )
    }

    private func getFont(fontSize: CGFloat) -> NSFont {
        NSFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: fontSize)
    }

    // MARK: draw functions
    private func drawPointText(in context: CGContext) {
        context.saveGState()

        context.translateBy(x: position.x + size.width / 2, y: position.y + size.height / 2)
        context.rotate(by: rotation * .pi / 180.0)
        context.translateBy(x: -size.width / 2, y: -size.height / 2)
        context.scaleBy(x: scale.width, y: scale.height)

        attributedString.draw(at: .zero)

        context.restoreGState()
    }

    private func drawParagraphText(in context: CGContext) {
        context.saveGState()

        context.translateBy(x: position.x + size.width / 2, y: position.y + size.height / 2)
        context.rotate(by: rotation * .pi / 180.0)
        context.translateBy(x: -size.width / 2, y: -size.height / 2)

        let drawRect = CGRect(origin: .zero, size: size)

        attributedString.draw(in: drawRect)

        context.restoreGState()
    }

    override func draw(in context: CGContext) {
        switch typeStyle {
        case .point:
            drawPointText(in: context)
        case .paragraph:
            drawParagraphText(in: context)
        }
    }
}
