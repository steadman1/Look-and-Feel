//
//  LFAllElementsPreview.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//

import SwiftUI

struct LFAllElementsPreview: View {
    @State private var input_InputBox: String = ""
    
    @State private var selected_InputSelectionBox: String = ""
    @State private var input_InputSelectionBox: String = ""
    
    @State private var input_NumericInputBox: CGFloat = 0
    
    @State private var selected_SelectionBox: String = ""
    
    let options: [String] = ["one", "two", "three", "four", "hello", "world", "looooooooooong"]
    
    var body: some View {
        VStack {
            LFButton(.none) {
                Text("none")
            } action: { p() }
            LFButton(.equal) {
                Text("equal")
            } action: { p() }
            LFButton(.parallel) {
                Text("parallel")
            } action: { p() }
            
            LFInputBox($input_InputBox) {
                Text("input box")
            }
            
            LFInputSelectionBox(
                $selected_InputSelectionBox,
                input: $input_InputSelectionBox,
                options: options,
                symbol: { Text("🔹") },
                placeholder: { Text("placeholder") },
                option: { Text($0) }
            )
            
            LFNumericInputBox(
                $input_NumericInputBox,
                step: 0.25,
                label: { Text("LBL:") },
                placeholder: { Text("placeholder") },
                unit: { Text("pt") }
            )
            
            LFSelectionBox(
                $selected_SelectionBox,
                options: options,
                symbol: { Text("🔹") },
                placeholder: { Text("placeholder") },
                option: { Text($0) }
            )
            
            LFSelectionBox(
                $selected_SelectionBox,
                options: options,
                placeholder: { Text("placeholder") },
                option: { Text($0) }
            )
        }
    }
    
    func p() {
        print("hello world")
    }
}

#Preview {
    LFAllElementsPreview()
        .padding(32)
        .frame(width: 400)
}
