//
//  GameCard.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

struct GameCard: View {
    var name: String
    var winner: String
    var colour: String
    var created: Date
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color(hex: colour)
            
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    Text(winner[0])
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(name)
                        .foregroundColor(.white)
                        .font(.callout)
                }.frame(maxHeight: .infinity)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Spacer()
                    Text(created.toString(format: "MMM dd"))
                        .foregroundColor(.white)
                        .font(.caption)
                }.frame(maxHeight: .infinity)
            }.padding(.all)
        }
        .frame(height: 130)
        .cornerRadius(24)
        .shadow(color: Color(hex: colour), radius: 4)
    }
}

struct GameCard_Previews: PreviewProvider {
    static var previews: some View {
        GameCard(name: "🎄 Xmas 7s", winner: "Jake", colour: "FF00FF", created: Date())
            .padding(.horizontal)
    }
}
