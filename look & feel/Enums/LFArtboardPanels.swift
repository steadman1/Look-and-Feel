//
//  LFArtboardPanels.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//

enum LFArtboardLeadingPanel: Int, PanelCase {
    case layers
    
    var description: String {
        switch self {
        case .layers: return "Layers"
        }
    }
}

enum LFArtboardTrailingPanel: Int, PanelCase {
    case design, constants
    
    var description: String {
        switch self {
        case .design: return "Design"
        case .constants: return "Constants"
        }
    }
}
