//
//  Number.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-22.
//

import Foundation

extension Int {
    static func sumDigits(digits: [Self]) -> Self {
        var n = 0;
        var sum = 0;
        while n < digits.count {
            sum += 10.pow(toPower: n) * digits[n]
            n += 1
        }
        
        return sum
    }
    
    func pow(toPower: Int) -> Int {
            guard toPower > 0 else { return 1 }
            return Array(repeating: self, count: toPower).reduce(1, *)
        }
    
    func digits(radix: Self = 10) -> [Self] {
        sequence(state: self) { quotient in
            guard quotient > 0
            else { return nil }
            
            let division = quotient.quotientAndRemainder(dividingBy: radix)
            quotient = division.quotient
            return division.remainder
        }
        .reversed()
    }
    
    func addDigit(digit: Int) -> Self {
        var digits = self.digits()
        digits.append(digit)
        digits = digits.reversed()
        return Self.sumDigits(digits: digits)
    }
    
    func removeDigit() -> Self {
        var digits = self.digits()
        digits.popLast()
        return Self.sumDigits(digits: digits)
    }
}
