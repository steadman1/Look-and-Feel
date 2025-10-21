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

    var anchor: CGPoint { self.mirrorVertical.mirrorHorizontal.point }

    var point: CGPoint {
        switch self {
        case .topLeft:
            return .init(x: 0, y: 0)
        case .top:
            return .init(x: 0.5, y: 0)
        case .topRight:
            return .init(x: 1, y: 0)
        case .left:
            return .init(x: 0, y: 0.5)
        case .right:
            return .init(x: 1, y: 0.5)
        case .bottomLeft:
            return .init(x: 0, y: 1)
        case .bottom:
            return .init(x: 0.5, y: 1)
        case .bottomRight:
            return .init(x: 1, y: 1)
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
