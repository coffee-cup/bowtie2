//
//  Colours.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-22.
//

import SwiftUI

struct Theme: Codable {
    var name: String
    var colours: [String]
    var startPoint: CodableUnitPoint
    var endPoint: CodableUnitPoint
    var requiresPremium: Bool = true
    
    init(name: String, colours: [String], start: UnitPoint, end: UnitPoint, requiresPremium: Bool = true) {
        self.name = name
        self.colours = colours
        self.startPoint = CodableUnitPoint(from: start)
        self.endPoint = CodableUnitPoint(from: end)
        self.requiresPremium = requiresPremium
    }
}

extension Theme {
    var gradient: LinearGradient {
        return LinearGradient(gradient: Gradient(colors: self.colours.map({ c in Color(hex: c) })), startPoint: self.startPoint.unitPoint, endPoint: self.endPoint.unitPoint)
    }
}

struct AppIcon {
    var name: String
    var filename: String
    var requiresPremium: Bool
}

let themes: [Theme] = [
    Theme(name: "Default", colours: ["FFA07A", "FF1493"], start: .topLeading, end: .bottomTrailing, requiresPremium: false),
    Theme(name: "Holiday Red", colours: ["E50010", "FF3D4B"], start: .topLeading, end: .bottomTrailing, requiresPremium: false),
    Theme(name: "Holiday Green", colours: ["00873E", "04BA57"], start: .topLeading, end: .bottomTrailing, requiresPremium: false),
    Theme(name: "Atlas", colours: ["FEAC5E", "C779D0", "35E7F3"], start: .topLeading, end: .bottomTrailing),
    Theme(name: "Timber", colours: ["fc00ff", "00dbde"], start: .topLeading, end: .bottomTrailing),
    Theme(name: "Earth", colours: ["20BF55", "01BAEF"], start: .topLeading, end: .bottomTrailing),
    Theme(name: "Sunrise", colours: ["FF5F6D", "FFC371"], start: .topLeading, end: .bottomTrailing),
    Theme(name: "Cherryblossoms", colours: ["FBD3E9", "BB377D"], start: .topLeading, end: .bottomTrailing),
    Theme(name: "Rose Water", colours: ["E55D87", "5FC3E4"], start: .topLeading, end: .bottomTrailing),
    Theme(name: "Peach", colours: ["ED4264", "FFEDBC"], start: .topLeading, end: .bottomTrailing),
    Theme(name: "Instagram", colours: ["833ab4", "fd1d1d", "fcb045"], start: .topLeading, end: .bottomTrailing),
    Theme(name: "Messenger", colours: ["00c6ff", "0072ff"], start: .topLeading, end: .bottomTrailing),
//    Theme(name: "Rainbow", colours: ["9400D3", "4B0082", "0000FF", "00FF00", "FFFF00", "FF7F00", "FF0000"], start: .topLeading, end: .bottomTrailing),
]

var icons: [AppIcon] = [
    AppIcon(name: "Default", filename: "primary", requiresPremium: false),
    AppIcon(name: "Holiday Red", filename: "xmas-red", requiresPremium: false),
    AppIcon(name: "Holiday Green", filename: "xmas-green", requiresPremium: false),
    AppIcon(name: "Winter", filename: "winter", requiresPremium: true),
    AppIcon(name: "Atlas", filename: "atlas", requiresPremium: true),
    AppIcon(name: "Timber", filename: "timber", requiresPremium: true),
    AppIcon(name: "Earth", filename: "earth", requiresPremium: true),
    AppIcon(name: "Greenish", filename: "greenish", requiresPremium: true),
    AppIcon(name: "Sunrise", filename: "sunrise", requiresPremium: true),
    AppIcon(name: "Cherryblossoms", filename: "cherryblossoms", requiresPremium: true),
]
