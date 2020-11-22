//
//  Array.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import Foundation

extension Array where Element: Hashable {
    func similar() -> Self {
        var used = [Element: Bool]()
        
        return self.filter { used.updateValue(true, forKey: $0) != nil }
    }
    
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}
