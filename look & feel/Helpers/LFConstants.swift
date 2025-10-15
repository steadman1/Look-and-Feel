//
//  LFConstants.swift
//  look & feel
//
//  Created by Spencer Steadman on 9/29/25.
//

import Foundation
import CoreGraphics
import SwiftUI

struct LFConst {
    /// 1 pt
    static let stroke: CGFloat = 1
    
    /// 2 pts
    static let shadowDepth: CGFloat = 2
    
    /// 3 pts
    static let shadowDepthHover: CGFloat = 3
    
    struct Fonts {
        /// 10pts, semibold weight
        static let smallIcon: Font = .system(size: 10, weight: .semibold)
        
        /// 14pts, regular weight
        static let mediumIcon: Font = .system(size: 14, weight: .regular)
    }
    
    struct Space {
        /// 4 pts
        static let xSmall: CGFloat = 4
        
        /// 8 pts
        static let small: CGFloat = 8
        
        /// 16 pts
        static let medium: CGFloat = 16
        
        /// 24 pts
        static let large: CGFloat = 24
        
        /// 32 pts
        static let xLarge: CGFloat = 32
    }
    
    struct Radius {
        /// 8 pts
        static let small: CGFloat = 4
        
        /// 8 pts
        static let regular: CGFloat = 8
        
        /// 16 pts
        static let large: CGFloat = 16
        
        /// 24 pts
        static let xLarge: CGFloat = 24
    }
}
