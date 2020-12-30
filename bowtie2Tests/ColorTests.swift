//
//  ColorTests.swift
//  bowtie2Tests
//
//  Created by Jake Runzer on 2020-12-30.
//

import XCTest
import SwiftUI
@testable import bowtie2

class ColorTests: XCTestCase {
    func testColorFromHex() throws {
        let c1 = Color(hex: "ff0000")
        XCTAssertEqual(c1.toComponents().red, 255)
        XCTAssertEqual(c1.toComponents().green, 0)
        XCTAssertEqual(c1.toComponents().blue, 0)
        
        let c2 = Color(hex: "5CFF2E")
        XCTAssertEqual(c2.toComponents().red, 92)
        XCTAssertEqual(c2.toComponents().green, 255)
        XCTAssertEqual(c2.toComponents().blue, 46)
        
        let c3 = Color(hex: "e9b221")
        XCTAssertEqual(c3.toComponents().red, 233)
        XCTAssertEqual(c3.toComponents().green, 178)
        XCTAssertEqual(c3.toComponents().blue, 33)
    }
    
    func testConvertToHex() throws {
        XCTAssertEqual(Color(hex: "ff0000").hexString, "#ff0000")
        XCTAssertEqual(Color(hex: "5CFF2E").hexString, "#5cff2e")
        XCTAssertEqual(Color(hex: "e9b221").hexString, "#e9b221")
    }
}

