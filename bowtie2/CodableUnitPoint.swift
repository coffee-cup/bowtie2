//
//  CodableUnitPoint.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-06.
//

import Foundation
import SwiftUI

class CodableUnitPoint: Codable {
    var unitPoint: UnitPoint
    
    enum CodingKeys: CodingKey {
        case x, y
    }
    
    init(from unitPoint: UnitPoint) {
        self.unitPoint = unitPoint
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        unitPoint = UnitPoint(x: x, y: y)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(unitPoint.x, forKey: .x)
        try container.encode(unitPoint.y, forKey: .y)
    }
}
