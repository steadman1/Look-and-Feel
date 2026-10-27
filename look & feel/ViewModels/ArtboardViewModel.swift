//
//  ArtboardViewModel.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//

import Foundation
import Combine
import SwiftUI
import GameplayKit

class ArtboardViewModel: ObservableObject, CustomStringConvertible {

    @Published var action: LFToolbarAction = .selection
    @Published var mouseDragState: LFDragState = .inactive
    
    @Published var panOffset: CGPoint = .zero
    @Published var zoom: CGFloat = 1
    
    @Published private(set) var layers: [LFLayer] = []
    @Published private(set) var selection: Set<UUID>
    @Published private(set) var firstSelection: UUID?
    @Published private(set) var recentSelection: UUID?

    private var layersByID: [UUID: LFLayer] = [:]
    
    init(layers: [LFLayer] = [], selection: [UUID] = []) {
        self.selection = Set<UUID>(selection)

        layers.forEach { self.addLayer($0) }
        
        if let first = selection.first {
            self.firstSelection = first
        }
    }

    /// Seed the live editing state from a document's layers. Used when a document
    /// is opened (or created) so the canvas reflects the persisted design.
    convenience init(document: LFDocument, selection: [UUID] = []) {
        self.init(layers: document.layers, selection: selection)
    }
    
    var description: String {
        return "ArtboardViewModel(frames: \(layers.description), selection:\(selection.description))"
    }
    
    func addLayer(_ layer: LFLayer) {
        layers.append(layer)
        layersByID[layer.id] = layer
    }

    /// Replace a layer (matched by `id`) with an updated value and trigger a
    /// re-render. This is how the canvas writes back mutations to value-type layers.
    func updateLayer(_ layer: LFLayer) {
        guard let index = layers.firstIndex(where: { $0.id == layer.id }) else { return }
        layers[index] = layer
        layersByID[layer.id] = layer
    }
    
    func removeFrames(with ids: Set<UUID>) {
        layers.removeAll { ids.contains($0.id) }

        for id in ids {
            layersByID.removeValue(forKey: id)
        }

        selection.subtract(ids)
        if let first = firstSelection, ids.contains(first) {
            firstSelection = nil
        }
    }
}



// MARK: frame intersection helpers
extension ArtboardViewModel {
    func intersect(at mouseLocation: CGPoint) -> LFLayer? {
        for layer in self.layers {
            if layer.frame.contains(mouseLocation) {
                return layer
            }
        }
        return nil
    }
}

// MARK: selection setters
extension ArtboardViewModel {
    func clearSelection() {
        selection.removeAll()
        firstSelection = nil
        recentSelection = nil
    }

    func singleSelect(_ id: UUID) {
        selection.removeAll()
        firstSelection = id
        recentSelection = id
        selection.insert(id)
    }

    func multiSelect(_ id: UUID) {
        // get position of id in layers array and set all inbetween most recent and id
        guard let newIndex = self.layers.firstIndex(where: { $0.id == id }) else { return }
        guard let recentIndex = self.layers.firstIndex(where: { $0.id == recentSelection }) else {
            self.toggleSelection(id)
            return
        }

        for index in min(recentIndex, newIndex)...max(recentIndex, newIndex) {
            selection.insert(self.layers[index].id)
        }

        recentSelection = id
    }

    func addSelection(_ id: UUID) {
        selection.insert(id)

        if firstSelection == nil {
            firstSelection = id
        }

        recentSelection = id
    }

    func removeSelection(_ id: UUID) {
        selection.remove(id)

        if recentSelection == id {
            if selection.count > 1 {
                recentSelection = selection.first { $0 != firstSelection }
            } else {
                recentSelection = firstSelection
            }
        }

        if firstSelection == id {
            if selection.count > 1 {
                firstSelection = selection.first { $0 != recentSelection }
            } else {
                firstSelection = recentSelection
            }
        }

        if selection.isEmpty {
            firstSelection = nil
            recentSelection = nil
        }
    }

    func toggleSelection(_ id: UUID) {
        if selection.contains(id) {
            removeSelection(id)
        } else {
            addSelection(id)
        }
    }
}

// MARK: selection getters and binding selection getters
extension ArtboardViewModel {
    var selectionLayers: [LFLayer] {
        self.selection.compactMap { self.layersByID[$0] }
    }
    
    /// Whether the first selected layer exposes width/height controls.
    var firstSelectionIsResizable: Bool {
        guard let id = self.firstSelection, let layer = self.layersByID[id] else { return false }
        return layer.isResizable
    }

    /// Whether the first selected layer exposes typography controls.
    var firstSelectionIsTypographic: Bool {
        guard let id = self.firstSelection, let layer = self.layersByID[id] else { return false }
        return layer.isTypographic
    }

    /// A `Binding` to the first selected layer, for SwiftUI dynamic member lookup
    /// (`.position.x`, `.name`, …). The getter looks the layer up by id so it always
    /// reflects the current value; the setter writes the updated value back.
    func firstSelectionBinding() -> Binding<LFLayer>? {
        guard let id = self.firstSelection, let initial = self.layersByID[id] else {
            return nil
        }

        return Binding<LFLayer>(
            get: { self.layersByID[id] ?? initial },
            set: { self.updateLayer($0) }
        )
    }

    func findTopLeftMostSelectedLayer() -> LFLayer? {
        // thanks gemini
        // self.selectionLayers is an array of the selected LFLayer objects.
        // The complexity of creating this array is O(n), where n is the number of selected items.

        // The min(by:) operation also iterates through all n elements once.
        return self.selectionLayers.min { layerA, layerB in
            // Assuming LFLayer has a 'position: CGPoint' property
            if layerA.position.y < layerB.position.y {
                return true // layerA is higher up (smaller y)
            } else if layerA.position.y == layerB.position.y {
                // If they are at the same y-level, check the x-position
                return layerA.position.x < layerB.position.x
            } else {
                return false // layerB is higher up
            }
        }
    }

    static var overloadedPreview: ArtboardViewModel {
        var layers: [LFLayer] = []
        for i in 0..<5000 {
            let path = LFPath(
                name: "Varied Shape \(i)",
                position: CGPoint(x: Double(i) * 50, y: Double(i) * 50),
                size: .init(width: 50, height: 50),
                fill: i % 2 == 0 ? .green : .orange,
                stroke: i % 3 == 0 ? .clear : .white,
                strokeWidth: CGFloat(i % 10),
                strokePosition: .center,
                points: [],
                isClosed: false
            )
            layers.append(LFLayer(path))
        }

        return ArtboardViewModel(layers: layers)
    }

    static var preview: ArtboardViewModel {
        ArtboardViewModel(document: .preview)
    }
}
