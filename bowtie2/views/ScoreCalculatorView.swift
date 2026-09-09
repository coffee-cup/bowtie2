//
//  ScoreCalculatorView.swift
//  bowtie2
//

import SwiftUI

struct ScoreCalculator {
    enum Operation: Equatable {
        case add
        case subtract

        var symbol: String {
            switch self {
            case .add:
                return "+"
            case .subtract:
                return "−"
            }
        }
    }

    private(set) var operands: [Int]
    private(set) var operations: [Operation] = []
    private(set) var currentOperand: Int?
    private(set) var accumulatedValue: Int
    private(set) var isEnteringInitialValue = false

    init(initialValue: Int) {
        operands = [initialValue]
        accumulatedValue = initialValue
    }

    var expression: String {
        var components = [String(operands[0])]

        for (index, operation) in operations.enumerated() {
            components.append(operation.symbol)

            if operands.indices.contains(index + 1) {
                components.append(String(operands[index + 1]))
            } else if index == operations.count - 1, let currentOperand {
                components.append(String(currentOperand))
            }
        }

        return components.joined(separator: " ")
    }

    var result: Int? {
        guard let operation = operations.last, let currentOperand else {
            return accumulatedValue
        }

        return calculate(accumulatedValue, operation, currentOperand)
    }

    var canCommit: Bool {
        result != nil
    }

    mutating func enterDigit(_ digit: Int) {
        guard (0...9).contains(digit) else { return }

        if operations.isEmpty {
            let existingValue = isEnteringInitialValue ? accumulatedValue : 0
            guard let newValue = append(digit, to: existingValue) else { return }

            operands[0] = newValue
            accumulatedValue = newValue
            isEnteringInitialValue = true
            return
        }

        let existingValue = currentOperand ?? 0
        guard let newValue = append(digit, to: existingValue) else { return }
        currentOperand = newValue
    }

    mutating func enterOperation(_ operation: Operation) {
        if let currentOperand {
            guard let newValue = result else { return }
            operands.append(currentOperand)
            accumulatedValue = newValue
            self.currentOperand = nil
            operations.append(operation)
        } else if operations.isEmpty || operations.count < operands.count {
            operations.append(operation)
        } else {
            operations[operations.count - 1] = operation
        }
    }

    mutating func deleteDigit() {
        if let currentOperand {
            if currentOperand < 10 {
                self.currentOperand = nil
            } else {
                self.currentOperand = currentOperand / 10
            }
            return
        }

        if !operations.isEmpty, operations.count == operands.count {
            operations.removeLast()
            return
        }

        if operands.count > 1 {
            let previousOperands = Array(operands.dropLast())
            guard let previousValue = accumulatedResult(for: previousOperands) else { return }

            currentOperand = operands.removeLast()
            accumulatedValue = previousValue
            deleteDigit()
            return
        }

        accumulatedValue /= 10
        operands[0] = accumulatedValue
        isEnteringInitialValue = true
    }

    mutating func clear() {
        self = ScoreCalculator(initialValue: 0)
    }

    private func append(_ digit: Int, to value: Int) -> Int? {
        let (shiftedValue, multiplyOverflow) = value.multipliedReportingOverflow(by: 10)
        let (newValue, addOverflow) = shiftedValue.addingReportingOverflow(digit)

        guard !multiplyOverflow, !addOverflow else { return nil }
        return newValue
    }

    private func accumulatedResult(for values: [Int]) -> Int? {
        guard var value = values.first else { return nil }

        for index in values.indices.dropFirst() {
            guard operations.indices.contains(index - 1),
                  let nextValue = calculate(value, operations[index - 1], values[index]) else {
                return nil
            }
            value = nextValue
        }

        return value
    }

    private func calculate(_ lhs: Int, _ operation: Operation, _ rhs: Int) -> Int? {
        let calculation: (partialValue: Int, overflow: Bool)

        switch operation {
        case .add:
            calculation = lhs.addingReportingOverflow(rhs)
        case .subtract:
            calculation = lhs.subtractingReportingOverflow(rhs)
        }

        guard !calculation.overflow, calculation.partialValue != .min else { return nil }
        return calculation.partialValue
    }
}

private struct CalculatorKeyButton: View {
    @EnvironmentObject private var settings: UserSettings

    let title: String
    var systemImage: String?
    let accessibilityLabel: String
    let accessibilityIdentifier: String
    var width: CGFloat = 76
    var height: CGFloat = 76
    var isThemed = false
    var isDisabled = false
    let action: () -> Void

    private var cornerRadius: CGFloat {
        min(width, height) / 2
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                keyBackground

                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 25, weight: .medium))
                } else {
                    Text(title)
                        .font(.system(size: title.count > 1 ? 25 : 34, weight: .medium))
                        .monospacedDigit()
                }
            }
            .foregroundColor(isThemed ? .white : .primary)
            .frame(width: width, height: height)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .opacity(isDisabled ? 0.35 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    @ViewBuilder
    private var keyBackground: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        if isThemed {
            shape.fill(settings.theme.gradient)
        } else {
            shape
                .fill(Color(.tertiarySystemFill))
                .overlay(shape.stroke(Color.primary.opacity(0.06), lineWidth: 1))
        }
    }
}

struct ScoreCalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: UserSettings

    @State private var calculator: ScoreCalculator
    let onCommit: (Int) -> Void

    private let keySize: CGFloat = 76
    private let keySpacing: CGFloat = 12

    init(initialValue: Int, onCommit: @escaping (Int) -> Void) {
        _calculator = State(initialValue: ScoreCalculator(initialValue: initialValue))
        self.onCommit = onCommit
    }

    var body: some View {
        NavigationStack {
            VStack {
                calculatorDisplay

                calculatorKeypad

                Spacer(minLength: 20)
            }
            .navigationTitle("Calculate Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
        }
    }

    private var calculatorKeypad: some View {
        VStack(spacing: keySpacing) {
            HStack(spacing: keySpacing) {
                CalculatorKeyButton(
                    title: "AC",
                    accessibilityLabel: "Clear",
                    accessibilityIdentifier: "calculator.key.clear"
                ) {
                    calculator.clear()
                }

                CalculatorKeyButton(
                    title: "",
                    systemImage: "delete.left",
                    accessibilityLabel: "Delete digit",
                    accessibilityIdentifier: "calculator.key.delete"
                ) {
                    calculator.deleteDigit()
                }

                CalculatorKeyButton(
                    title: "−",
                    accessibilityLabel: "Subtract",
                    accessibilityIdentifier: "calculator.key.subtract",
                    isThemed: true
                ) {
                    calculator.enterOperation(.subtract)
                }

                CalculatorKeyButton(
                    title: "+",
                    accessibilityLabel: "Add",
                    accessibilityIdentifier: "calculator.key.add",
                    isThemed: true
                ) {
                    calculator.enterOperation(.add)
                }
            }

            HStack(alignment: .bottom, spacing: keySpacing) {
                VStack(spacing: keySpacing) {
                    ForEach([[7, 8, 9], [4, 5, 6], [1, 2, 3]], id: \.self) { row in
                        HStack(spacing: keySpacing) {
                            ForEach(row, id: \.self) { digit in
                                CalculatorKeyButton(
                                    title: String(digit),
                                    accessibilityLabel: String(digit),
                                    accessibilityIdentifier: "calculator.key.\(digit)"
                                ) {
                                    calculator.enterDigit(digit)
                                }
                            }
                        }
                    }

                    CalculatorKeyButton(
                        title: "0",
                        accessibilityLabel: "0",
                        accessibilityIdentifier: "calculator.key.0",
                        width: keySize * 3 + keySpacing * 2
                    ) {
                        calculator.enterDigit(0)
                    }
                }

                VStack(spacing: keySpacing) {
                    Color.clear
                        .frame(width: keySize, height: keySize)
                        .accessibilityHidden(true)

                    CalculatorKeyButton(
                        title: "=",
                        accessibilityLabel: "Enter",
                        accessibilityIdentifier: "calculator.key.enter",
                        width: keySize,
                        height: keySize * 3 + keySpacing * 2,
                        isThemed: true,
                        isDisabled: !calculator.canCommit
                    ) {
                        guard let result = calculator.result else { return }
                        onCommit(result)
                        dismiss()
                    }
                }
            }
        }
        .padding(.bottom)
        .frame(maxWidth: .infinity)
    }

    private var calculatorDisplay: some View {
        VStack(spacing: 4) {
            Text(calculator.expression)
                .font(.headline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibilityLabel("Expression \(calculator.expression)")

            Text(calculator.result.map(String.init) ?? "Too large")
                .font(.system(size: 120, weight: .bold))
                .monospacedDigit()
                .padding(.vertical, 8)
                .gradientForeground(gradient: settings.theme.gradient)
                .lineLimit(1)
                .minimumScaleFactor(0.35)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .accessibilityLabel(calculator.result.map(String.init) ?? "Number too large")
        }
        .frame(maxWidth: 340)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct ScoreCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreCalculatorView(initialValue: 14, onCommit: { _ in })
            .environmentObject(UserSettings())
    }
}
