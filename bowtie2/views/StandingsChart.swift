//
//  StandingsChart.swift
//  bowtie2
//

import SwiftUI

/// Each player's place after every round, ranked with the same rules as the scoreboard.
struct GameStandings {
    struct Entry {
        let name: String
        let colour: String
        /// Zero-based place after each round.
        let places: [Int]
    }

    let entries: [Entry]
    let rounds: Int

    init(scores: [PlayerScore], winnerSort: WinnerSort) {
        let totals = scores.map(\.summedHistory)
        let names = scores.map { $0.player?.wrappedName ?? "" }
        let rounds = totals.map(\.count).max() ?? 0
        var places = Array(repeating: [Int](), count: scores.count)

        for round in 0..<rounds {
            // Players who are behind on rounds keep their latest total.
            let values = totals.map { $0.isEmpty ? 0 : $0[min(round, $0.count - 1)] }
            var order = scores.indices.sorted { a, b in
                values[a] != values[b] ? values[a] > values[b] : names[a] < names[b]
            }
            if winnerSort == .scoreLowest {
                order.reverse()
            }
            for (place, index) in order.enumerated() {
                places[index].append(place)
            }
        }

        entries = scores.indices.map { index in
            Entry(name: names[index],
                  colour: scores[index].player?.wrappedColor ?? "000000",
                  places: places[index])
        }
        self.rounds = rounds
    }
}

/// Draws one line per player through precomputed points, with a dot at each round.
struct StandingsPlot: View {
    let colours: [String]
    let points: [[CGPoint]]
    /// Points past this index extend a line without a dot (e.g. down to a score chip).
    let dotCount: Int
    var lineWidth: CGFloat = 3.5
    var dotDiameter: CGFloat = 10
    var background: Color = Color(.tertiarySystemGroupedBackground)

    var body: some View {
        Canvas { context, _ in
            for (index, line) in points.enumerated() where line.count > 1 {
                var path = Path()
                path.addLines(line)
                context.stroke(path,
                               with: .color(Color(hex: colours[index])),
                               style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            }
            for (index, line) in points.enumerated() {
                for point in line.prefix(dotCount) {
                    let rect = CGRect(x: point.x - dotDiameter / 2, y: point.y - dotDiameter / 2,
                                      width: dotDiameter, height: dotDiameter)
                    let dot = Path(ellipseIn: rect)
                    context.fill(dot, with: .color(Color(hex: colours[index])))
                    context.stroke(dot, with: .color(background), lineWidth: 2)
                }
            }
        }
    }
}

/// Places run top to bottom, rounds left to right. Sized for the iPhone graph card.
struct StandingsChart: View {
    let standings: GameStandings

    private let labelWidth: CGFloat = 32
    private let markerSize: CGFloat = 26

    var body: some View {
        GeometryReader { geo in
            let players = standings.entries.count
            let rounds = standings.rounds
            let left = labelWidth
            let right = markerSize / 2 + 8
            let top = markerSize / 2 + 4
            let bottom = markerSize / 2 + 8
            let columnSpacing = (geo.size.width - left - right) / CGFloat(max(rounds - 1, 1))
            let rowSpacing = (geo.size.height - top - bottom) / CGFloat(max(players - 1, 1))
            let x = { (round: Int) in left + columnSpacing * CGFloat(round) }
            let y = { (place: Int) in top + rowSpacing * CGFloat(place) }
            let points = standings.entries.map { entry in
                entry.places.enumerated().map { CGPoint(x: x($0.offset), y: y($0.element)) }
            }

            ZStack(alignment: .topLeading) {
                StandingsPlot(colours: standings.entries.map(\.colour),
                              points: points,
                              dotCount: max(rounds - 1, 0),
                              dotDiameter: min(10, columnSpacing * 0.5, rowSpacing * 0.5))

                ForEach(0..<players, id: \.self) { place in
                    Text("\(place + 1)")
                        .font(.caption.weight(.bold))
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                        .position(x: labelWidth / 2, y: y(place))
                }

                ForEach(Array(standings.entries.enumerated()), id: \.offset) { index, entry in
                    if let last = points[index].last {
                        PlayerInitialMarker(name: entry.name, colour: entry.colour, size: markerSize)
                            .position(last)
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Standings after each round")
        .accessibilityIdentifier("game.standings")
    }
}

private struct PlayerInitialMarker: View {
    let name: String
    let colour: String
    let size: CGFloat

    var body: some View {
        Text(name.prefix(1))
            .font(.system(size: size * 0.46, weight: .heavy))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(Circle().fill(Color(hex: colour)))
            .overlay(Circle().stroke(Color(.tertiarySystemGroupedBackground), lineWidth: 2))
    }
}

/// Compact icon switch between the progression graph and the standings chart.
struct GameChartToggle: View {
    @Binding var selection: GameChart

    var body: some View {
        HStack(spacing: 2) {
            option(.graph, systemImage: "chart.line.uptrend.xyaxis", label: "Graph")
            option(.standings, systemImage: "list.number", label: "Standings")
        }
        .padding(2)
        .background(Capsule().fill(Color.primary.opacity(0.06)))
    }

    private func option(_ chart: GameChart, systemImage: String, label: String) -> some View {
        let isSelected = selection == chart
        return Button {
            selection = chart
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .primary : .secondary)
                .frame(width: 36, height: 28)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(.systemBackground) : .clear)
                        .shadow(color: .black.opacity(isSelected ? 0.12 : 0), radius: 2, y: 1)
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("gameChart.\(chart.rawValue)")
    }
}
