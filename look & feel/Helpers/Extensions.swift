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

extension String {
    func size(
        with font: NSFont,
        applying attributes: [NSAttributedString.Key: Any],
        constrainedToWidth width: CGFloat = .greatestFiniteMagnitude
    ) -> CGSize {
        var newAttributes = attributes
        newAttributes[.font] = font
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let drawingOptions: NSString.DrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]

        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: drawingOptions,
            attributes: newAttributes,
            context: nil
        )

        return CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
    }
}

extension NSFont {
    static func getAllFontNames() -> [String] {
        var allFontNames: [String] = []

        let fontManager = NSFontManager.shared

        for familyName in fontManager.availableFontFamilies.sorted() {
            if let fontNames = fontManager.availableMembers(ofFontFamily: familyName) {
                for fontMember in fontNames {
                    // fontMember is an array like [fontName, weight, traits, ...]
                    if let fontName = fontMember[0] as? String {
                        allFontNames.append(fontName)
                    }
                }
            }
        }

        return allFontNames
    }
}
