//
//  GameCard.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

struct GameCard: View {
    @ObservedObject var game: Game
    @EnvironmentObject var settings: UserSettings
    
    var square: some View {
        Group {
            if game.winner != nil {
                Text(game.winner?.wrappedName[0] ?? "🎀")
                    .foregroundColor(.white)
                    .font(.system(size: 48, weight: .bold))
                    .padding()
                    .frame(width: 100, height: 100)
                    .if(game.winner == nil) { $0.background(settings.theme.gradient) }
                    .if(game.winner != nil) { $0.background(Color(hex: game.winner?.wrappedColor ?? "#000000")) }
            } else {
                ZStack {
                    Image("bowtie").resizable().frame(width: 80, height: 80)
                }
                .frame(width: 100, height: 100)
                .background(settings.theme.gradient)
            }
        }
    }
    
    var date: some View {
        VStack {
            Text(game.wrappedCreated.toString(format: "MMM d"))
                .foregroundColor(Color(.tertiaryLabel))
                .font(.caption)
                .padding(.all, 8)
            
            Spacer()
        }
    }
    
    var gameInfo: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(game.wrappedName)
                .foregroundColor(.primary)
                .font(.title).fontWeight(.bold)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .padding(.bottom, 4)
            
            Text(game.scoresArray.map { score in  (score.player?.wrappedName ?? "") }.joined(separator: ", "))
                .foregroundColor(Color(.secondaryLabel))
                .font(.system(size: 14))
        }
        .padding(.vertical)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            square
            
            HStack {
                gameInfo
                
                Spacer()
                
                date
            }
        }
        .background(Color(.tertiarySystemGroupedBackground))
        .frame(minHeight: 100, idealHeight: 100)
        .cornerRadius(10)
    }
}

struct GameCard_Previews: PreviewProvider {
    static var previews: some View {
        GameCard(game: Game.gameByName(context: PersistenceController.preview.container.viewContext, name: "Tie")!)
            .environmentObject(UserSettings())
            .padding(.horizontal)
            .frame(height: 100)
    }
}
