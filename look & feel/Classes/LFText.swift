//
//  LFText.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import SwiftUI

class LFText: LFLayer, Resizable, Typographic, Colorable {
    
    // MARK: Resizable conformance
    @Published var size: CGSize
    
    // MARK: Typographic conformance
    @Published var fontName: String
    @Published var fontSize: Double
    @Published var leading: CGFloat
    @Published var letterSpacing: CGFloat
    @Published var paragraphStyle: ParagraphStyle
    
    // MARK: Colorable conformance
    @Published var fill: Color
    @Published var stroke: Color
    @Published var strokeWidth: CGFloat
    @Published var strokePosition: LFStrokePosition
    
    init(
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
        paragraphStyle: ParagraphStyle,
    ) {
        self.size = size
        
        self.fill = fill
        self.stroke = stroke
        self.strokeWidth = strokeWidth
        self.strokePosition = strokePosition
        
        self.fontName = fontName
        self.fontSize = fontSize
        self.leading = leading
        self.letterSpacing = letterSpacing
        self.paragraphStyle = paragraphStyle
        
        super.init(
            name: name,
            position: position,
            rotation: rotation
        )
    }
}
