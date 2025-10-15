//
//  Layer.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

import SwiftUI

class LFLayer: ObservableObject, Identifiable, Transformable {
    final let id: UUID
    
    @Published var name: String
    
    // MARK:  Transformable conformance
    @Published var position: CGPoint
    @Published var rotation: CGFloat
    
    init(
        id: UUID = UUID(),
        name: String,
        position: CGPoint,
        rotation: CGFloat,
    ) {
        self.id = id
        self.name = name
        self.position = position
        self.rotation = rotation
    }
    
    convenience init(id: UUID = UUID(), name: String) {
        self.init(
            id: id,
            name: name,
            position: .zero,
            rotation: 0
        )
    }
    
    func setPosition(_ with: CGPoint) {
        self.position = with
    }
    
    func setRotation(_ with: CGFloat) {
        self.rotation = with
    }
    
    // children should override
    open func draw() {
        // LFLayer objects shouldn't draw anything
    }
    
    @ViewBuilder
    var symbol: some View {
        Image(systemName: "rectangle.portrait")
    }
}
