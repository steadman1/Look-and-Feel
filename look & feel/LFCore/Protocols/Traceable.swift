//
//  Traceable.swift
//  look & feel
//

/// A layer defined by a bezier trace (control points).
protocol Traceable {
    var points: [LFBezierPoint] { get set }
    var isClosed: Bool { get set }
}
