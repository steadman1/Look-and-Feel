//
//  Sizeable.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import CoreGraphics
import Foundation

protocol Resizable: Transformable, Identifiable {
    var size: CGSize { get }
    var frame: CGRect { get }

    func setSize(_ newSize: CGSize)
}
