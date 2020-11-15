//
//  String.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-14.
//

import Foundation

extension String {
    subscript(idx: Int) -> String {
        String(self[index(startIndex, offsetBy: idx)])
    }
}
