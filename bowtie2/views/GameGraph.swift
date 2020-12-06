//
//  GameGraph.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-06.
//

import SwiftUI

struct GameGraph: View {
    @ObservedObject var game: Game
    
    var body: some View {
        GraphView(graph: Graph(lines: game.scoresArray.map { score in
            Line(colour: score.player?.wrappedColor ?? "000000",
                 points: score.summedHistory.map{ p in CGFloat(p) })
        }))
        .padding(.vertical)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

struct GameGraph_Previews: PreviewProvider {
    static var previews: some View {
        GameGraph(game: Game.gameByName(context: PersistenceController.preview.container.viewContext, name: "3000")!)
            .aspectRatio(16/9, contentMode: .fit)
            .padding(.all)
    }
}
