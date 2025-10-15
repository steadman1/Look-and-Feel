//
//  LFFrame.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//

import Foundation

class LFGroup: LFLayer {
    @Published var children: [LFLayer]
    
    init(
        name: String,
        children: [LFLayer]
    ) {
        self.children = children
        
        super.init(
            id: UUID(),
            name: "",
            position: .zero,
            rotation: 0
        )
    }
    
    override func setPosition(_ with: CGPoint) {
        for child in children {
            child.setPosition(
                CGPoint(
                    x: child.position.x + with.x,
                    y: child.position.y + with.y
                )
            )
        }
    }
    
    override func setRotation(_ with: CGFloat) {
        for child in children {
            child.setRotation(child.rotation + with)
        }
    }
}
