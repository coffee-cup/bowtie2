//
//  NumberTest.swift
//  bowtie2Tests
//
//  Created by Jake Runzer on 2020-12-14.
//

import XCTest
@testable import bowtie2

class NumberTests: XCTestCase {
    func testDigits() throws {
        XCTAssertEqual(0.digits, [0])
        XCTAssertEqual(1.digits, [1])
        XCTAssertEqual(100.digits, [1,0,0])
        XCTAssertEqual(1009.digits, [1,0,0,9])
    }
    
    func testAddDigit() throws {
        XCTAssertEqual(0.addDigit(digit: 1), 1)
        XCTAssertEqual(1.addDigit(digit: 2), 12)
        XCTAssertEqual(100.addDigit(digit: 1), 1001)
    }
    
    func testRemoveDigit() throws {
        XCTAssertEqual(0.removeDigit(), 0)
        XCTAssertEqual(1.removeDigit(), 0)
        XCTAssertEqual(10.removeDigit(), 1)
        XCTAssertEqual(123.removeDigit(), 12)
        XCTAssertEqual(800.removeDigit(), 80)
        XCTAssertEqual(8008.removeDigit(), 800)
    }
}

