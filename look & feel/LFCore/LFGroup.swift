//
//  LFGroup.swift
//  look & feel
//

import Foundation
import CoreGraphics

/// A group layer: an ordered collection of child layers that transform together.
///
/// Converted from the old `LFLayer` subclass to a `Codable` value type. Children
/// are `[LFLayer]` (the unified enum), so groups can nest arbitrarily and the
/// whole tree is a single serializable value.
struct LFGroup: Codable, Hashable {
    var base: LFBase
    var children: [LFLayer]

    init(
        id: UUID = UUID(),
        name: String,
        position: CGPoint = .zero,
        rotation: CGFloat = 0,
        children: [LFLayer]
    ) {
        self.base = LFBase(id: id, name: name, position: position, rotation: rotation)
        self.children = children
    }

    /// Convenience matching the old `LFGroup(name:children:)`.
    init(name: String, children: [LFLayer]) {
        self.init(name: name, children: children)
    }

    // MARK: - Transform helpers (propagate to all children, like the old class)

    mutating func setPosition(_ position: CGPoint) {
        let delta = CGPoint(x: position.x - base.position.x, y: position.y - base.position.y)
        base.position = position
        for index in children.indices {
            children[index].setPosition(
                CGPoint(x: children[index].position.x + delta.x,
                        y: children[index].position.y + delta.y)
            )
        }
    }

    mutating func setRotation(_ rotation: CGFloat) {
        let delta = rotation - base.rotation
        base.rotation = rotation
        for index in children.indices {
            children[index].setRotation(children[index].rotation + delta)
        }
    }

    // MARK: - Bounding box (in the group's local space)

    /// The union of all children's frames, expressed relative to the group's own
    /// origin. Used as the group's effective `size` for selection frames.
    var boundingBox: CGRect {
        guard !children.isEmpty else { return .zero }

        var box = CGRect(origin: .zero, size: children[0].size)
        for child in children {
            let localOrigin = CGPoint(
                x: child.position.x - base.position.x,
                y: child.position.y - base.position.y
            )
            let childFrame = CGRect(origin: localOrigin, size: child.size)
            box = box.union(childFrame)
        }
        return box
    }

    /// Scale every child to fit `newSize` (relative to the current bounding box).
    mutating func resize(to newSize: CGSize) {
        let box = boundingBox
        guard box.width > 0, box.height > 0 else { return }
        let scaleX = newSize.width / box.width
        let scaleY = newSize.height / box.height

        for index in children.indices {
            var child = children[index]
            let oldSize = child.size
            child.setSize(CGSize(width: oldSize.width * scaleX, height: oldSize.height * scaleY))
            children[index] = child
        }
    }
}
