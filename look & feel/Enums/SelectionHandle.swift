//
//  SelectionHandle.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/14/25.
//

import AppKit

enum LFSelectionHandle {
    case topLeft, top, topRight, left, right, bottomLeft, bottom, bottomRight

    var mirrorHorizontal: LFSelectionHandle {
        switch self {
        case .topLeft:
            return .topRight
        case .topRight:
            return .topLeft
        case .left:
            return .right
        case .right:
            return .left
        case .bottomLeft:
            return .bottomRight
        case .bottomRight:
            return .bottomLeft
        default:
            return self
        }
    }
    
    var mirrorVertical: LFSelectionHandle {
        switch self {
        case .topLeft:
            return .bottomLeft
        case .top:
            return .bottom
        case .topRight:
            return .bottomRight
        case .bottomLeft:
            return .topLeft
        case .bottom:
            return .top
        case .bottomRight:
            return .topRight
        default:
            return self
        }
    }
    
    var cursor: NSCursor {
        switch self {
        case .topLeft, .bottomRight:
            return .frameResize(position: .topLeft, directions: .all)
        case .topRight, .bottomLeft:
            return .frameResize(position: .topRight, directions: .all)
        case .top, .bottom:
            return .frameResize(position: .top, directions: .all)
        case .left, .right:
            return .frameResize(position: .left, directions: .all)
        }
    }
}
