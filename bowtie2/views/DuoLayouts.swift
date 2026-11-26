//
//  DuoLayouts.swift
//  bowtie2
//
//  Game layout for screens with a fold (iPhone Duo inner display). The fold splits
//  the screen into two panes: player tiles in the first, and the chart or score
//  entry in the second. The same layout is used in every orientation and hinge
//  position; only the split axis changes.
//

import CoreData
import SwiftUI

extension GeometryProxy {
    /// The fold's frame (including its margins) in this proxy's coordinate space, or nil
    /// when the screen doesn't fold.
    var foldFrame: CGRect? {
        if #available(iOS 27.1, *) {
            return reservedRegions(kind: .division, options: .includeInactive).first?.frame
        }
        return nil
    }
}

struct DuoGameView: View {
    @EnvironmentObject private var settings: UserSettings
    @ObservedObject var game: Game
    let scores: [PlayerScore]
    let fold: CGRect
    let addScore: (PlayerScore, Int) -> Void
    let onHistory: (PlayerScore) -> Void

    @State private var enteringID: NSManagedObjectID?
    @State private var entry = 0
    @State private var isNegative = false
    @State private var calculator: ScoreCalculator?

    private let inset: CGFloat = 16

    private var entering: PlayerScore? {
        scores.first { $0.objectID == enteringID }
    }

    private var showsChart: Bool {
        settings.showGraph && game.maxNumberOfEntries >= 2
    }

    var body: some View {
        GeometryReader { geo in
            let (first, second) = panes(in: geo.size)
            let scale = Sparkline.Scale(scores: scores, maxEntries: game.maxNumberOfEntries)

            ZStack(alignment: .topLeading) {
                if let entering {
                    tiles(scores, in: first, scale: scale)
                    entryPanel(for: entering, size: second.size)
                        .frame(width: second.width, height: second.height)
                        .position(x: second.midX, y: second.midY)
                } else if showsChart {
                    tiles(scores, in: first, scale: scale)
                    GameGraph(game: game, expands: true)
                        .frame(width: second.width, height: second.height)
                        .position(x: second.midX, y: second.midY)
                } else {
                    let split = (scores.count + 1) / 2
                    tiles(Array(scores.prefix(split)), in: first, scale: scale)
                    tiles(Array(scores.dropFirst(split)), in: second, scale: scale)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .onChange(of: scores.map(\.objectID)) { ids in
            if let enteringID, !ids.contains(enteringID) {
                closeEntry()
            }
        }
    }

    /// The two sides of the fold, inset from the screen edges.
    private func panes(in size: CGSize) -> (CGRect, CGRect) {
        let bounds = CGRect(origin: .zero, size: size)
        let first: CGRect
        let second: CGRect
        if fold.height >= fold.width {
            first = CGRect(x: 0, y: 0, width: max(fold.minX, 0), height: size.height)
            second = CGRect(x: fold.maxX, y: 0, width: max(size.width - fold.maxX, 0), height: size.height)
        } else {
            first = CGRect(x: 0, y: 0, width: size.width, height: max(fold.minY, 0))
            second = CGRect(x: 0, y: fold.maxY, width: size.width, height: max(size.height - fold.maxY, 0))
        }
        return (first.intersection(bounds).insetBy(dx: inset, dy: inset),
                second.intersection(bounds).insetBy(dx: inset, dy: inset))
    }

    private func open(_ score: PlayerScore) {
        guard score.objectID != enteringID else { return }
        enteringID = score.objectID
        entry = 0
        isNegative = false
        calculator = nil
    }

    private func closeEntry() {
        enteringID = nil
        entry = 0
        isNegative = false
        calculator = nil
    }

    // MARK: Tiles

    @ViewBuilder
    private func tiles(_ group: [PlayerScore], in rect: CGRect, scale: Sparkline.Scale) -> some View {
        let layout = TileLayout(count: group.count, in: rect.size, spacing: 10)
        let rows = stride(from: 0, to: group.count, by: layout.columns).map {
            Array(group[$0..<min($0 + layout.columns, group.count)])
        }
        let grid = VStack(spacing: 10) {
            ForEach(rows.indices, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(rows[row], id: \.objectID) { score in
                        tile(for: score, size: layout.tileSize, scale: scale)
                    }
                }
            }
        }
        .frame(minWidth: rect.width, minHeight: rect.height)

        Group {
            if let axis = layout.scrollAxis {
                ScrollView(axis == .horizontal ? .horizontal : .vertical, showsIndicators: false) { grid }
            } else {
                grid
            }
        }
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)
    }

    private func tile(for score: PlayerScore, size: CGSize, scale: Sparkline.Scale) -> some View {
        let scoreFont = min(size.height * 0.32, size.width * 0.24, 76)
        let showsSparkline = showsChart && size.height >= 60
        let isEntering = score.objectID == enteringID

        return Button {
            open(score)
        } label: {
            VStack(spacing: 2) {
                Spacer(minLength: 0)
                Text(String(score.currentScore))
                    .font(.system(size: scoreFont, weight: .heavy))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                Text(score.displayName)
                    .font(.system(size: max(12, scoreFont * 0.3), weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
                if showsSparkline {
                    Sparkline(values: scale.values(for: score), scale: scale)
                        .frame(height: size.height * 0.2)
                }
            }
            .padding(.horizontal, 6)
            .foregroundColor(.white)
            .frame(width: size.width, height: size.height)
            .background(score.displayColour)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(.label), lineWidth: isEntering ? 3 : 0)
            )
            .overlay(alignment: .topTrailing) {
                TurnBadge(turns: score.wrappedHistory.count, maxEntries: game.maxNumberOfEntries)
                    .padding(6)
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onHistory(score)
            } label: {
                HStack {
                    Text("View History")
                    Image(systemName: "archivebox")
                }
            }
        }
        .accessibilityIdentifier("scorePlayer.\(score.displayName)")
        .accessibilityAddTraits(isEntering ? .isSelected : [])
    }

    // MARK: Entry

    private func entryPanel(for score: PlayerScore, size: CGSize) -> some View {
        let isWide = size.width > size.height

        return VStack(spacing: 12) {
            HStack(spacing: 10) {
                Text("Enter Score for \(score.displayName)")
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                calculatorButton
                Spacer(minLength: 0)
                Button {
                    closeEntry()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color(.systemBackground)))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
                .accessibilityIdentifier("score.close")
            }

            if isWide {
                HStack(spacing: 20) {
                    entryDisplay
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    keypad(for: score)
                        .frame(width: min(300, size.width * 0.45))
                }
            } else {
                entryDisplay
                    .frame(maxHeight: .infinity)
                keypad(for: score)
                    .frame(height: min(size.height * 0.5, 320))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
    }

    @ViewBuilder
    private var entryDisplay: some View {
        if let calculator {
            VStack(spacing: 4) {
                (calculator.showsExpression ? calculator.expressionText(accent: settings.theme.accent) : Text(" "))
                    .font(.headline)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(calculator.result.map(String.init) ?? "Too large")
                    .font(.system(size: 96, weight: .bold))
                    .monospacedDigit()
                    .gradientForeground(gradient: settings.theme.gradient)
                    .lineLimit(1)
                    .minimumScaleFactor(0.35)
                    .frame(maxHeight: .infinity)
            }
        } else {
            ScoreView(score: entry, isNegative: $isNegative)
        }
    }

    private var calculatorButton: some View {
        let isActive = calculator != nil
        return Button {
            calculator = isActive ? nil : ScoreCalculator(initialValue: isNegative ? -entry : entry)
        } label: {
            Image("ScoreCalculator")
                .renderingMode(.template)
                .foregroundColor(isActive ? .white : .primary)
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(isActive ? AnyShapeStyle(settings.theme.gradient) : AnyShapeStyle(Color(.systemBackground)))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Calculator")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    @ViewBuilder
    private func keypad(for score: PlayerScore) -> some View {
        if calculator == nil {
            numberPad(for: score)
        } else {
            calculatorPad
        }
    }

    private func numberPad(for score: PlayerScore) -> some View {
        VStack(spacing: 4) {
            ForEach([[1, 2, 3], [4, 5, 6], [7, 8, 9]], id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { digit in
                        key(String(digit), identifier: "score.key.\(digit)") {
                            entry = entry.addDigit(digit: digit)
                        }
                    }
                }
            }
            HStack(spacing: 4) {
                key(systemImage: "delete.left", label: "Delete", identifier: "score.key.delete") {
                    entry = entry.removeDigit()
                }
                key("0", identifier: "score.key.0") {
                    entry = entry.addDigit(digit: 0)
                }
                key("Go", identifier: "score.go", themed: true) {
                    addScore(score, isNegative ? -entry : entry)
                    closeEntry()
                }
            }
        }
    }

    private var calculatorPad: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 4
            let keyWidth = (geo.size.width - spacing * 3) / 4
            let keyHeight = (geo.size.height - spacing * 4) / 5
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    key(systemImage: "delete.left", label: "Delete digit", identifier: "calculator.key.delete") {
                        calculator?.deleteDigit()
                    }
                    .frame(width: keyWidth)
                    key("AC", label: "Clear", identifier: "calculator.key.clear") {
                        calculator?.clear()
                    }
                    .frame(width: keyWidth * 2 + spacing)
                    key("−", label: "Subtract", identifier: "calculator.key.subtract", themed: true,
                        selected: calculator?.pendingOperation == .subtract) {
                        calculator?.enterOperation(.subtract)
                    }
                    .frame(width: keyWidth)
                }
                .frame(height: keyHeight)

                HStack(alignment: .top, spacing: spacing) {
                    VStack(spacing: spacing) {
                        ForEach([[7, 8, 9], [4, 5, 6], [1, 2, 3]], id: \.self) { row in
                            HStack(spacing: spacing) {
                                ForEach(row, id: \.self) { digit in
                                    key(String(digit), identifier: "calculator.key.\(digit)") {
                                        calculator?.enterDigit(digit)
                                    }
                                }
                            }
                            .frame(height: keyHeight)
                        }
                        key("0", identifier: "calculator.key.0") {
                            calculator?.enterDigit(0)
                        }
                        .frame(height: keyHeight)
                    }
                    .frame(width: keyWidth * 3 + spacing * 2)

                    VStack(spacing: spacing) {
                        key("+", label: "Add", identifier: "calculator.key.add", themed: true,
                            selected: calculator?.pendingOperation == .add) {
                            calculator?.enterOperation(.add)
                        }
                        .frame(height: keyHeight)
                        key("=", label: "Enter", identifier: "calculator.key.enter", themed: true,
                            disabled: !(calculator?.canCommit ?? false)) {
                            guard let result = calculator?.result, result != .min else { return }
                            isNegative = result < 0
                            entry = abs(result)
                            calculator = nil
                        }
                    }
                    .frame(width: keyWidth)
                }
            }
        }
    }

    private func key(_ title: String? = nil,
                     systemImage: String? = nil,
                     label: String? = nil,
                     identifier: String,
                     themed: Bool = false,
                     selected: Bool = false,
                     disabled: Bool = false,
                     action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 22, weight: .medium))
                } else {
                    Text(title ?? "")
                        .font(.system(size: themed ? 20 : 24, weight: themed ? .bold : .regular))
                        .monospacedDigit()
                }
            }
            .foregroundColor(themed ? .white : .primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(themed ? AnyShapeStyle(settings.theme.gradient) : AnyShapeStyle(Color(.systemBackground)))
            )
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(disabled ? 0.35 : 1)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .accessibilityLabel(label ?? title ?? "")
        .accessibilityIdentifier(identifier)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// Picks the grid that gives each tile the most room. Past 12 players tiles keep the
/// 12-player size and the grid scrolls along the pane's longer side.
private struct TileLayout {
    let columns: Int
    let tileSize: CGSize
    let scrollAxis: Axis?

    init(count: Int, in size: CGSize, spacing: CGFloat) {
        let fitted = max(min(count, 12), 1)
        var best = (columns: 1, size: CGSize.zero)
        for columns in 1...fitted {
            let rows = Int(ceil(Double(fitted) / Double(columns)))
            let tile = CGSize(width: (size.width - spacing * CGFloat(columns - 1)) / CGFloat(columns),
                              height: (size.height - spacing * CGFloat(rows - 1)) / CGFloat(rows))
            if min(tile.width, tile.height) > min(best.size.width, best.size.height) {
                best = (columns, tile)
            }
        }
        tileSize = CGSize(width: max(best.size.width, 0), height: max(best.size.height, 0))

        if count > 12 {
            let fittedRows = Int(ceil(Double(fitted) / Double(best.columns)))
            if size.width >= size.height {
                columns = Int(ceil(Double(count) / Double(fittedRows)))
                scrollAxis = .horizontal
            } else {
                columns = best.columns
                scrollAxis = .vertical
            }
        } else {
            columns = best.columns
            scrollAxis = nil
        }
    }
}

/// Turn count, red when the player is behind on rounds. Matches PlayerScoreCard.
private struct TurnBadge: View {
    let turns: Int
    let maxEntries: Int

    var body: some View {
        let behind = turns < maxEntries
        Text("\(turns)")
            .font(.caption)
            .frame(minWidth: 16, minHeight: 16)
            .padding(.all, 4)
            .foregroundColor(behind ? .white : Color(.secondaryLabel))
            .background(behind ? Color.red : Color(.tertiarySystemGroupedBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(behind ? 0.2 : 0), radius: 5)
    }
}

private extension PlayerScore {
    var displayName: String { player?.wrappedName ?? "" }
    var displayColour: Color { Color(hex: player?.wrappedColor ?? "000000") }
}

/// A player's running total drawn inside their tile, on a scale shared by every tile.
private struct Sparkline: View {
    struct Scale {
        let low: CGFloat
        let high: CGFloat
        let maxEntries: Int

        init(scores: [PlayerScore], maxEntries: Int) {
            let all = scores.flatMap(\.summedHistory)
            low = CGFloat(all.min() ?? 0)
            high = CGFloat(all.max() ?? 0)
            self.maxEntries = maxEntries
        }

        func values(for score: PlayerScore) -> [CGFloat] {
            score.summedHistory.map { high == low ? 0.5 : (CGFloat($0) - low) / (high - low) }
        }
    }

    let values: [CGFloat]
    let scale: Scale

    var body: some View {
        GeometryReader { geo in
            let points = values.enumerated().map { index, value in
                CGPoint(x: geo.size.width * CGFloat(index) / CGFloat(max(scale.maxEntries - 1, 1)),
                        y: geo.size.height - 4 - value * (geo.size.height - 8))
            }
            if let first = points.first, let last = points.last {
                Path { path in
                    path.move(to: CGPoint(x: first.x, y: geo.size.height))
                    points.forEach { path.addLine(to: $0) }
                    path.addLine(to: CGPoint(x: last.x, y: geo.size.height))
                    path.closeSubpath()
                }
                .fill(Color.white.opacity(0.16))

                Path { path in
                    path.addLines(points)
                }
                .stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
        }
        .accessibilityHidden(true)
    }
}
