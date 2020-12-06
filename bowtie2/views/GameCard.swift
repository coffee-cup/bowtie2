//
//  GameCard.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

struct GameCard: View {
    @ObservedObject var game: Game
    
    var body: some View {
        HStack(spacing: 16) {
            Text(game.winner?.wrappedName[0] ?? "🎀")
                .foregroundColor(.white)
                .font(.system(size: 48, weight: .bold))
                .padding()
                .frame(width: 100, height: 100)
                .if(game.winner == nil) { $0.background(          LinearGradient(gradient: primaryGradient, startPoint: .topLeading, endPoint: .bottomTrailing)) }
                .if(game.winner != nil) { $0.background(Color(hex: game.winner?.wrappedColor ?? "#000000")) }
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(game.wrappedName)
                        .foregroundColor(.primary)
                        .font(.title).fontWeight(.bold)
                        .padding(.bottom, 4)
                    
                    Text(game.scoresArray.map { score in  (score.player?.wrappedName ?? "") }.joined(separator: ", "))
                        .foregroundColor(Color(.secondaryLabel))
                        .font(.system(size: 14))
                }
                
                Spacer()
                
                VStack {
                    Text(game.wrappedCreated.toString(format: "MMM d"))
                        .foregroundColor(Color(.tertiaryLabel))
                        .font(.caption)
                        .padding(.all, 8)
                    
                    Spacer()
                }
            }
        }
        .background(Color(.tertiarySystemGroupedBackground))
        .frame(height: 100)
        .cornerRadius(10)
    }
}

struct GameCard_Previews: PreviewProvider {
    static var previews: some View {
        GameCard(game: Game.gameByName(context: PersistenceController.preview.container.viewContext, name: "Blitz")!)
            .padding(.horizontal)
    }
}
