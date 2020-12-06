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
            Text("\(score)")
                .foregroundColor(.white)
                .font(.system(size: 48, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.all)
                .frame(width: 120, height: 100)
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
                        .foregroundColor(Color(.secondaryLabel))
                        .background(numTurns < maxScoresGame ? Color.red : Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(numTurns < maxScoresGame ? 0.2 : 0), radius: 5)
                    
                    Spacer()
                }
                .padding(.all, 8)
            }
        }
        .background(Color(.tertiarySystemGroupedBackground))
        .frame(height: 100)
        .cornerRadius(10)
    }
    
//    var body: some View {
//        ZStack(alignment: .leading) {
//            Color(hex: colour)
//
//            HStack {
//                VStack(alignment: .leading) {
//                    Spacer()
//                    Text("\(score)")
//                        .font(.system(size: 48, weight: .bold))
//                        .foregroundColor(.white)
//                        .multilineTextAlignment(.center)
//
//                    Text(name)
//                        .foregroundColor(.white)
//                        .font(.callout)
//                }.frame(maxHeight: .infinity)
//
//                Spacer()
//
//                VStack(alignment: .leading) {
//                    Text("\(numTurns)")
//                        .font(.caption)
//                        .frame(minWidth: 16, minHeight: 16)
//                        .padding(.all, 4)
//                        .foregroundColor(Color.white)
//                        .background(numTurns < maxScoresGame ? Color.red : Color(hex: colour).darker(by: 15))
//                        .cornerRadius(20)
//                        .shadow(color: Color.black.opacity(numTurns < maxScoresGame ? 0.2 : 0), radius: 5)
//
//                    Spacer()
//                }
//            }.padding(.all)
//        }
//        .frame(height: 120)
//        .cornerRadius(24)
////        .shadow(color: Color(hex: colour), radius: 4)
//    }
}

struct PlayerScoreCard_Previews: PreviewProvider {
    static var previews: some View {
        PlayerScoreCard(name: "Jake",
                        colour: "FF00FF",
                        score: 100,
                        numTurns: 1,
                        maxScoresGame: 1)
            .padding(.horizontal)
    }
}
