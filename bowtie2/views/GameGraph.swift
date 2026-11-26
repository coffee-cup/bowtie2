//
//  GameGraph.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-06.
//

import SwiftUI

struct GameGraph: View {
    @EnvironmentObject var settings: UserSettings
    @ObservedObject var game: Game
    /// Fill the available height instead of using the scroll-friendly fixed height.
    var expands = false

    private let rowSpacing: CGFloat = 36

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                GameChartToggle(selection: $settings.gameChart)
            }
            .padding([.top, .trailing], 8)

            switch settings.gameChart {
            case .graph:
                GraphView(graph: Graph(lines: game.scoresArray.map { score in
                    Line(colour: score.player?.wrappedColor ?? "000000",
                         points: score.summedHistory.map { p in CGFloat(p) })
                }))
                .padding(.vertical)
                .frame(height: expands ? nil : 200)
                .frame(maxHeight: expands ? .infinity : nil)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Score progression")
                .accessibilityIdentifier("game.graph")
            case .standings:
                let standings = GameStandings(scores: game.scoresArray, winnerSort: game.winnerSort)
                StandingsChart(standings: standings)
                    .frame(height: expands ? nil : max(200, rowSpacing * CGFloat(standings.entries.count)))
                    .frame(maxHeight: expands ? .infinity : nil)
            }
        }
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

struct GameGraph_Previews: PreviewProvider {
    static var previews: some View {
        GameGraph(game: Game.gameByName(context: PersistenceController.preview.container.viewContext, name: "3000")!)
            .environmentObject(UserSettings())
            .padding(.all)
    }
}
