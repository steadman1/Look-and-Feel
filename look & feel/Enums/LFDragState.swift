//
//  LFDragState.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/14/25.
//

import CoreGraphics

enum LFDragState {
    case inactive
    
    case resizing(handle: LFSelectionHandle, initialMouse: CGPoint, initialFrames: [CGRect])

    case relocating(initialMouse: CGPoint, initialFrames: [CGRect])
}
