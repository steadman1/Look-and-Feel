//
//  PanelCase.swift
//  look & feel
//
//  Created by Spencer Steadman on 10/8/25.
//


protocol PanelCase: CaseIterable, RawRepresentable, CustomStringConvertible where RawValue: Hashable { }
