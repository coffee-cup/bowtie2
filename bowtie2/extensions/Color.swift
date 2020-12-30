//
//  Color.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-14.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toComponents() -> (red: Int, green: Int, blue: Int, opacity: Int) {
        let components = UIColor(self).cgColor.components!
            
        let r = (Int)(round(components[0] * 255))
        let g = (Int)(round(components[1] * 255))
        let b = (Int)(round(components[2] * 255))
        let a = (Int)(round(components[3] * 255))
        
        return (r, g, b, a)
    }
    
    var hexString: String {
        let (r, g, b, a) = self.toComponents()
//        let rgb: Int = (Int)(r) << 16 | (Int)(round(g * 255)) << 8 | (Int)(round(b * 255)) << 0
        let rgb: Int = r << 16 | g << 8 | b << 0
        
        return String(format: "#%06x", rgb)
    }
    
//    func toHex(alpha: Bool = false) -> String {
//        let (r, g, b, a) = self.toComponents()
//
//        if alpha {
//            return String(format: "#%02X%02X%02X%02X",
//                          Int(round(r * 255)), Int(round(g * 255)),
//                          Int(round(b * 255)), Int(round(a * 255)))
//        } else {
//            return String(format: "#%02X%02X%02X", Int(round(r * 255)),
//                          Int(round(g * 255)), Int(round(b * 255)))
//        }
//    }
    
//    func lighter(by percentage: CGFloat = 30.0) -> Color {
//        return self.adjust(by: abs(percentage) )
//    }
//    
//    func darker(by percentage: CGFloat = 30.0) -> Color {
//        return self.adjust(by: -1 * abs(percentage) )
//    }
    
//    func adjust(by percentage: CGFloat = 30.0) -> Color {
//        let components = self.toComponents()
//        return Color(red: min(Double(components.red + percentage/100), 1.0),
//                     green: min(Double(components.green + percentage/100), 1.0),
//                     blue: min(Double(components.blue + percentage/100), 1.0),
//                     opacity: Double(components.opacity))
//    }
}
