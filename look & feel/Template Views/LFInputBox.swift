//
//  LFInputBox.swift
//  look & feel
//
//  Created by Spencer Steadman on 9/29/25.
//

import SwiftUI

struct LFInputBox<Content: View>: View {
    
    @State private var isHovering: Bool = false
    @State private var isMouseDown: Bool = false
    @State private var isActive: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    @Binding var input: String
    
    let content: Content
    
    public init(
        _ input: Binding<String>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._input = input
        self.content = content()
    }
    
    var body: some View {
        let lfMouseInteractionBundle = lfMouseInteractionBundle(
            .input,
            isHovering: isHovering,
            isFocused: isTextFieldFocused,
            hasError: false
        )
        
        ZStack(alignment: .leading) {
            TextField("", text: $input)
                .textFieldStyle(.plain)
                .focused($isTextFieldFocused)
            
            if input.isEmpty {
                content
                    .foregroundStyle(Color.tertiaryText)
                    .onTapGesture { isTextFieldFocused = true }
            }
        }
        .animation(.lfEaseOut, value: lfMouseInteractionBundle.id)
        .padding(
            .all,
            LFConst.Space.small
        )
        .background(lfMouseInteractionBundle.background)
        .clipShape(RoundedRectangle(cornerRadius: LFConst.Radius.regular))
        .overlay {
            RoundedRectangle(cornerRadius: LFConst.Radius.regular)
                .stroke(
                    lfMouseInteractionBundle.stroke,
                    lineWidth: LFConst.stroke
                )
                .animation(.lfEaseOut, value: lfMouseInteractionBundle.id)
        }
        .onHover { isHovering in
            self.isHovering = isHovering
        }
    }
}

#Preview {
    @Previewable @State var input: String = ""
    VStack {
        LFInputBox($input) {
            Text("hello world")
        }
    }.frame(maxWidth: 300, maxHeight: 300)
        .background(Color.foreground)
}
