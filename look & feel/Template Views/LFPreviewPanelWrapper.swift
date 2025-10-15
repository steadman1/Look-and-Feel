//
//  LFPreviewPanelWrapper.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//

import SwiftUI

struct LFPreviewPanelWrapper<Content: View>: View {
    
    let name: String
    let content: Content
    
    init(name: String, content: @escaping () -> Content) {
        self.name = name
        self.content = content()
    }
    
    var body: some View {
        VStack {
            HStack {
                LFButton {
                    Text(name)
                } action: { }
                
                Spacer()
            }
            .padding(.horizontal, LFConst.Space.medium)
            .padding(.vertical, LFConst.shadowDepthHover)
            
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.foreground)
    }
}
