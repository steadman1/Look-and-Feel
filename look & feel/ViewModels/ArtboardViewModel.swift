//
//  ArtboardViewModel.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//

import Foundation
import Combine
import SwiftUI

class ArtboardViewModel: ObservableObject, CustomStringConvertible {
    
    @Published var mouseDragState: LFDragState = .inactive
    
    @Published var panOffset: CGPoint = .zero
    @Published var zoom: CGFloat = 1
    
    @Published private(set) var layers: [LFLayer] = []
    @Published private(set) var selection: Set<UUID>
    @Published private(set) var firstSelection: UUID?
    
    private var layersByID: [UUID: LFLayer] = [:]
    
    private var layerCancellables: [UUID: AnyCancellable] = [:]
    
    init(layers: [LFLayer] = [], selection: [UUID] = []) {
        self.selection = Set<UUID>(selection)
        
        layers.forEach { self.addLayer($0) }
        
        if let first = selection.first {
            self.firstSelection = first
        }
    }
    
    var description: String {
        return "ArtboardViewModel(frames: \(layers.description), selection:\(selection.description))"
    }
    
    func singleSelect(_ id: UUID) {
        selection.removeAll()
        firstSelection = id
        selection.insert(id)
    }
    
    func addSelection(_ id: UUID) {
        selection.insert(id)
        
        firstSelection = id
    }
    
    func removeSelection(_ id: UUID) {
        selection.remove(id)
        
        if firstSelection == id {
            // unordered, so get random ?
            self.firstSelection = selection.isEmpty ? nil : selection.randomElement()
        }
    }
    
    func toggleSelection(_ id: UUID) {
        if selection.contains(id) {
            removeSelection(id)
        } else {
            addSelection(id)
        }
    }
    
    func addLayer(_ layer: LFLayer) {
        layers.append(layer)
        layersByID[layer.id] = layer
        
        let cancellable = layer.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        layerCancellables[layer.id] = cancellable
    }
    
    func removeFrames(with ids: Set<UUID>) {
        layers.removeAll { ids.contains($0.id) }
        
        for id in ids {
            layerCancellables[id]?.cancel()
            layerCancellables.removeValue(forKey: id)
            layersByID.removeValue(forKey: id)
        }
        
        selection.subtract(ids)
        if let first = firstSelection, ids.contains(first) {
            firstSelection = nil
        }
    }
}

extension ArtboardViewModel {
    var selectionLayers: [LFLayer] {
        self.selection.compactMap { self.layersByID[$0] }
    }
    
    func doesFirstSelectionConform<P>(_ to: P.Type) -> Bool {
        guard let id = self.firstSelection, let layer = self.layersByID[id] else { return false }
        return layer is P
    }
    
    func firstSelectionBinding() -> Binding<LFLayer>? {
        guard let id = self.firstSelection, let layer = self.layersByID[id] else {
            return nil
        }
        
        return Binding<LFLayer>(
            get: {
                return layer
            },
            set: { updatedLayer in
                guard let index = self.layers.firstIndex(where: { $0.id == updatedLayer.id }) else { return }
                
                self.layers[index] = updatedLayer
                self.layersByID[updatedLayer.id] = updatedLayer
            }
        )
    }
    
    func firstSelectionBinding<P>(_ conformingTo: P.Type) -> Binding<P>? {
        guard let id = self.firstSelection else {
            return nil
        }

        guard self.layersByID[id] is P else {
            return nil
        }
        
        return Binding<P>(
            get: {
                return self.layersByID[id]! as! P
            },
            set: { updatedLayer in
                guard let updatedLayer = updatedLayer as? LFLayer else { return }

                if let index = self.layers.firstIndex(where: { $0.id == updatedLayer.id }) {
                    self.layers[index] = updatedLayer
                    self.layersByID[updatedLayer.id] = updatedLayer
                }
            }
        )
    }
    
    static var preview: ArtboardViewModel {
        return ArtboardViewModel(
            layers: [
                LFPath(name: "Shape 1", position: .zero, size: .init(width: 100, height: 100), fill: .white, stroke: .clear, strokeWidth: 0, strokePosition: .center, points: [], isClosed: false),
                LFPath(name: "Shape 2", position: .init(x: 50, y: 100), size: .init(width: 70, height: 120), fill: .blue, stroke: .clear, strokeWidth: 0, strokePosition: .center, points: [], isClosed: false),
                LFPath(name: "Shape 3", position: .init(x: 140, y: 20), size: .init(width: 50, height: 50), fill: .yellow, stroke: .clear, strokeWidth: 0, strokePosition: .center, points: [], isClosed: false)
            ],
            selection: [
                //id
            ]
        )
    }
}
