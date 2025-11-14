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
    var size: CGSize {
        CGSize(
            width: attributedString.size().width * scale.width,
            height: attributedString.size().height * scale.height
        )
    }

    @Published var reflection: [LFReflectionAxis]

    // MARK: Typographic conformance
    @Published var fontFamily: String
    @Published var fontMember: String
    @Published var fontSize: CGFloat
    @Published var leading: CGFloat
    @Published var tracking: CGFloat
    @Published var typeStyle: LFTypeStyle
    @Published var paragraphStyle: LFParagraphStyle
    internal var scale: CGSize

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

        reflection: [LFReflectionAxis] = [],
        
        fill: NSColor,
        stroke: NSColor,
        strokeWidth: CGFloat,
        strokePosition: LFStrokePosition,
        
        fontFamily: String,
        fontMember: String = "",
        fontSize: CGFloat,
        leading: CGFloat,
        tracking: CGFloat,
        typeStyle: LFTypeStyle,
        paragraphStyle: LFParagraphStyle,
    ) {
        self.text = text

        self.reflection = reflection

        self.fill = fill
        self.stroke = stroke
        self.strokeWidth = strokeWidth
        self.strokePosition = strokePosition
        
        self.fontFamily = fontFamily
        self.fontMember = fontMember
        self.fontSize = fontSize
        self.leading = leading
        self.tracking = tracking
        self.typeStyle = typeStyle
        self.paragraphStyle = paragraphStyle
        self.scale = CGSize(width: 1, height: 1)

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

    // MARK: setters
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

    func setFont(_ familyName: String, with memberName: String) {
        self.fontFamily = familyName
        self.fontMember = (
            memberName.isEmpty
                ? NSFont.getAllFontMembers(for: familyName).first
                : NSFont.getAllFontMembers(for: familyName).first { $0.contains(memberName) }
        ) ?? ""
    }

    func setFontSize(_ fontSize: CGFloat) {
        self.fontSize = fontSize
    }

    func setLeading(_ leading: CGFloat) {
        self.leading = leading
    }

    func setTracking(_ tracking: CGFloat) {
        self.tracking = tracking
    }

    override var symbol: AnyView {
        AnyView (
            Image(systemName: "textformat")
                .fontWeight(.semibold)
        )
    }

    // MARK: getters
    private func getFont(fontSize: CGFloat) -> NSFont {
        let name = fontMember.isEmpty ? fontFamily : fontMember
        return NSFont(name: name, size: fontSize) ?? .systemFont(ofSize: fontSize)
    }

    // MARK: computed vars
    private var fontAttributes: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = leading
        paragraphStyle.alignment = NSTextAlignment.left

        return [
            .foregroundColor: fill,
            .strokeColor: stroke,
            .strokeWidth: strokeWidth,
            .paragraphStyle: paragraphStyle,
            .tracking: tracking
        ]
    }

    private var attributedString: NSAttributedString {
        return NSAttributedString(
            string: text,
            attributes: fontAttributes.merging(
                [.font: getFont(fontSize: fontSize)], uniquingKeysWith: { $1 }
            )
        )
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
