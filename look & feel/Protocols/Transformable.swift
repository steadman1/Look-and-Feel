//
//  Transformable.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import CoreGraphics
import Foundation

protocol Transformable: Identifiable {
    var id: UUID { get }
    var position: CGPoint { get }
    var rotation: CGFloat { get }
    
    func setPosition(_ with: CGPoint) -> Void
    func setRotation(_ with: CGFloat) -> Void
}
