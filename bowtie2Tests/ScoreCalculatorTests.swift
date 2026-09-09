//
//  ScoreCalculatorTests.swift
//  bowtie2Tests
//

import XCTest
@testable import bowtie2

final class ScoreCalculatorTests: XCTestCase {
    func testFirstDigitReplacesInitialDisplayValue() {
        var calculator = ScoreCalculator(initialValue: 14)

        calculator.enterDigit(2)

        XCTAssertEqual(calculator.expression, "2")
        XCTAssertEqual(calculator.result, 2)
    }

    func testAdditionAndSubtractionAreEvaluatedFromLeftToRight() {
        var calculator = ScoreCalculator(initialValue: 14)

        calculator.enterOperation(.add)
        calculator.enterDigit(2)
        calculator.enterDigit(3)

        XCTAssertEqual(calculator.result, 37)

        calculator.enterOperation(.subtract)
        calculator.enterDigit(8)

        XCTAssertEqual(calculator.expression, "14 + 23 − 8")
        XCTAssertEqual(calculator.result, 29)
    }

    func testSubtractionCanProduceNegativeResult() {
        var calculator = ScoreCalculator(initialValue: 14)

        calculator.enterOperation(.subtract)
        calculator.enterDigit(2)
        calculator.enterDigit(3)

        XCTAssertEqual(calculator.result, -9)
    }

    func testConsecutiveOperationReplacesPendingOperation() {
        var calculator = ScoreCalculator(initialValue: 14)

        calculator.enterOperation(.add)
        calculator.enterOperation(.subtract)

        XCTAssertEqual(calculator.expression, "14 −")
        XCTAssertEqual(calculator.result, 14)
    }

    func testDeletingTraversesOperatorsAndPreviousOperands() {
        var calculator = ScoreCalculator(initialValue: 14)

        calculator.enterOperation(.add)
        calculator.enterDigit(2)
        calculator.enterDigit(3)
        calculator.deleteDigit()

        XCTAssertEqual(calculator.expression, "14 + 2")
        XCTAssertEqual(calculator.result, 16)

        calculator.deleteDigit()

        XCTAssertEqual(calculator.expression, "14 +")
        XCTAssertEqual(calculator.result, 14)

        calculator.deleteDigit()

        XCTAssertEqual(calculator.expression, "14")
        XCTAssertEqual(calculator.result, 14)

        calculator.deleteDigit()

        XCTAssertEqual(calculator.expression, "1")
        XCTAssertEqual(calculator.result, 1)
    }

    func testDeletingTraversesAChainedCalculation() {
        var calculator = ScoreCalculator(initialValue: 14)

        calculator.enterOperation(.add)
        calculator.enterDigit(2)
        calculator.enterDigit(3)
        calculator.enterOperation(.subtract)
        calculator.enterDigit(8)

        calculator.deleteDigit()
        XCTAssertEqual(calculator.expression, "14 + 23 −")

        calculator.deleteDigit()
        XCTAssertEqual(calculator.expression, "14 + 23")
        XCTAssertEqual(calculator.result, 37)

        calculator.deleteDigit()
        XCTAssertEqual(calculator.expression, "14 + 2")
        XCTAssertEqual(calculator.result, 16)
    }

    func testEnteringDigitAfterDeletingOperatorContinuesPreviousOperand() {
        var calculator = ScoreCalculator(initialValue: 14)

        calculator.enterOperation(.add)
        calculator.enterDigit(2)
        calculator.enterDigit(3)
        calculator.enterOperation(.subtract)
        calculator.deleteDigit()
        calculator.enterDigit(4)

        XCTAssertEqual(calculator.expression, "14 + 234")
        XCTAssertEqual(calculator.result, 248)
    }

    func testEnteringDigitAfterDeletingNegativeInitialValuePreservesSign() {
        var calculator = ScoreCalculator(initialValue: -14)

        calculator.deleteDigit()
        calculator.enterDigit(2)

        XCTAssertEqual(calculator.expression, "-12")
        XCTAssertEqual(calculator.result, -12)
    }

    func testClearResetsEntireExpression() {
        var calculator = ScoreCalculator(initialValue: -4)

        calculator.enterOperation(.add)
        calculator.enterDigit(9)
        calculator.clear()

        XCTAssertEqual(calculator.expression, "0")
        XCTAssertEqual(calculator.result, 0)
    }

    func testTrailingOperationCommitsLastValidResult() {
        var calculator = ScoreCalculator(initialValue: 14)

        calculator.enterOperation(.add)

        XCTAssertEqual(calculator.result, 14)
        XCTAssertTrue(calculator.canCommit)
    }

    func testOverflowCannotBeCommitted() {
        var calculator = ScoreCalculator(initialValue: .max)

        calculator.enterOperation(.add)
        calculator.enterDigit(1)

        XCTAssertNil(calculator.result)
        XCTAssertFalse(calculator.canCommit)
    }

    func testIntMinimumCannotBeCommittedAsScoreMagnitude() {
        var calculator = ScoreCalculator(initialValue: -1)

        calculator.enterOperation(.subtract)
        for digit in String(Int.max).compactMap(\.wholeNumberValue) {
            calculator.enterDigit(digit)
        }

        XCTAssertNil(calculator.result)
        XCTAssertFalse(calculator.canCommit)
    }
}
