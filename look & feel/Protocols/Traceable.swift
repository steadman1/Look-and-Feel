//
//  Traceable.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/13/25.
//

protocol Traceable {
    var points: [LFBezierPoint] { get set }
    var isClosed: Bool { get set } // change to only get (?)
}
