//
//  Extensions.swift
//  look & feel
//
//  Created by Spencer Steadman on 9/29/25.
//

import SwiftUI

extension Animation {
    static let lfEaseOut: Animation = Animation.easeOut(duration: 0.1)
        
}

extension CGFloat {
    func toString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16
        formatter.groupingSeparator = ""
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
