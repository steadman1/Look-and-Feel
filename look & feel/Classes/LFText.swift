//
//  LFText.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import SwiftUI
import AppKit

class LFText: LFLayer, Resizable, Typographic, Colorable {

    @Published var text: String

    // MARK: Resizable conformance
    @Published var size: CGSize
    
    // MARK: Typographic conformance
    @Published var fontName: String
    @Published var fontSize: Double
    @Published var leading: CGFloat
    @Published var letterSpacing: CGFloat
    @Published var typeStyle: LFTypeStyle
    @Published var paragraphStyle: LFParagraphStyle

    let fontAttributes: [NSAttributedString.Key: Any]

    // MARK: Colorable conformance
    @Published var fill: Color
    @Published var stroke: Color
    @Published var strokeWidth: CGFloat
    @Published var strokePosition: LFStrokePosition
    
    init(
        text: String,
        name: String,
        position: CGPoint,
        size: CGSize,
        rotation: CGFloat = 0,
        
        fill: Color,
        stroke: Color,
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

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = leading
        paragraphStyle.alignment = NSTextAlignment.left

        self.fontAttributes = [
            .foregroundColor: NSColor.black,
            .strokeColor: NSColor.black,
            .strokeWidth: strokeWidth,
            .kern: letterSpacing,
            .paragraphStyle: paragraphStyle
        ]

        super.init(
            name: name,
            position: position,
            rotation: rotation
        )
    }

    var frame: CGRect {
        CGRect(
            origin: position,
            size: size
        )
    }

    func setSize(_ newSize: CGSize) {
        self.size = newSize
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

    private func getFontAttributes(with font: NSFont) -> [NSAttributedString.Key: Any] {
        var newAttributes: [NSAttributedString.Key : Any] = fontAttributes
        newAttributes[.font] = font
        return newAttributes
    }

    private func getMaxSize(
        for rect: CGRect,
        with attributes: [NSAttributedString.Key: Any],
        size: CGSize = .zero,
        accuracy: CGFloat = 100
    ) -> CGSize {
        if accuracy <= 0.01 { return size }

        let newSize = text.size(
            with: getFont(fontSize: size.width),
            applying: attributes
        )
        if newSize.width > rect.width {
            return getMaxSize(
                for: rect,
                with: attributes,
                size: CGSize(width: max(size.width - accuracy, 0), height: newSize.height),
                accuracy: accuracy / 10
            )
        }

        return getMaxSize(
            for: rect,
            with: attributes,
            size: CGSize(width: size.width + accuracy, height: newSize.height),
            accuracy: accuracy
        )
    }

    // MARK: draw functions
    private func drawPointText(in context: CGContext) {
        context.saveGState()

        let fontSize = getMaxSize(for: frame, with: fontAttributes).width
        let nsFont = NSFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: fontSize)
        let textBoxSize = text.size(with: nsFont, applying: getFontAttributes(with: nsFont), constrainedToWidth: frame.width)

        self.size = textBoxSize

        context.translateBy(x: position.x + size.width / 2, y: position.y + size.height / 2)
        context.rotate(by: rotation * .pi / 180.0)
        context.translateBy(x: -size.width / 2, y: -size.height / 2)

        let attrString = NSAttributedString(string: text, attributes: getFontAttributes(with: nsFont))

        let drawRect = CGRect(origin: .zero, size: size)

        attrString.draw(in: drawRect)

        context.restoreGState()
    }

    private func drawParagraphText(in context: CGContext) {
        context.saveGState()
        context.translateBy(x: position.x + size.width / 2, y: position.y + size.height / 2)

        context.rotate(by: rotation * .pi / 180.0)

        context.translateBy(x: -size.width / 2, y: -size.height / 2)

        let attrString = NSAttributedString(
            string: text,
            attributes: getFontAttributes(
                with: getFont(fontSize: fontSize)
            )
        )

        let drawRect = CGRect(origin: .zero, size: size)

        attrString.draw(in: drawRect)

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
