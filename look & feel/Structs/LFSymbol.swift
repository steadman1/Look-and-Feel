//
//  LFSymbol.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/23/25.
//

import SwiftUI

struct LFSymbol<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
    }
}
