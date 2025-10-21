//
//  LFCanvasTransformRequest.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/18/25.
//

import CoreGraphics

// use to tell function what context is not provided to canvas
// objects that should be accounted for within the function
enum LFCanvasTransformRequest: CaseIterable {
    case translate, rotate, scale
}
