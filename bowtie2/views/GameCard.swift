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
        ZStack(alignment: .leading) {
            Color(hex: game.winner?.wrappedColor ?? "000000")
            
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    Text(game.winner?.wrappedName[0] ?? "No")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(game.wrappedName)
                        .foregroundColor(.white)
                        .font(.callout)
                }.frame(maxHeight: .infinity)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Spacer()
                    Text(game.wrappedCreated.toString(format: "MMM dd"))
                        .foregroundColor(.white)
                        .font(.caption)
                }.frame(maxHeight: .infinity)
            }.padding(.all)
        }
        .frame(height: 120)
        .cornerRadius(24)
//        .shadow(color: Color(hex: colour), radius: 4)
    }
}

struct GameCard_Previews: PreviewProvider {
    static var previews: some View {
        GameCard(game: Game.gameByName(context: PersistenceController.preview.container.viewContext, name: "Blitz")!)
            .padding(.horizontal)
    }
}
