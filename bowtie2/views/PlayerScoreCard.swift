//
//  PlayerScoreCard.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-21.
//

import SwiftUI

struct PlayerScoreCard: View {
    var name: String
    var colour: String
    var score: Int
    var numTurns: Int
    var maxScoresGame: Int
    
    var body: some View {
        HStack(spacing: 20) {
            Text(String(score))
                .foregroundColor(.white)
                .font(.system(size: 48, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.all)
                .frame(width: 120, height: 80)
                .background(Color(hex: colour))
            
            HStack {
                Text(name)
                    .foregroundColor(.primary)
                    .font(.title).fontWeight(.bold)
                    .padding(.bottom, 4)
                
                Spacer()
                
                VStack(spacing: 0) {
                    Text("\(numTurns)")
                        .font(.caption)
                        .frame(minWidth: 16, minHeight: 16)
                        .padding(.all, 4)
                        .foregroundColor(numTurns < maxScoresGame ? Color.white : Color(.secondaryLabel))
                        .background(numTurns < maxScoresGame ? Color.red : Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(numTurns < maxScoresGame ? 0.2 : 0), radius: 5)
                    
                    Spacer()
                }
                .padding(.all, 8)
            }
        }
        .background(Color(.tertiarySystemGroupedBackground))
        .frame(height: 80)
        .cornerRadius(10)
    }
}

struct PlayerScoreCard_Previews: PreviewProvider {
    static var previews: some View {
        PlayerScoreCard(name: "Jake",
                        colour: "FF00FF",
                        score: 1000,
                        numTurns: 1,
                        maxScoresGame: 1)
            .padding(.horizontal)
    }
}
