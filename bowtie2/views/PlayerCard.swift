//
//  PlayerCard.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

struct PlayerCard: View {
    var name: String
    var colour: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color(hex: colour)
            
            VStack {
                Spacer()
                
                Text(name)
                    .font(.system(size: 28, weight: .bold))
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)
                    .foregroundColor(Color.white)
            }
            .padding(.all)
        }
        .frame(height: 100)
        .cornerRadius(24)
    }
}

struct PlayerCard_Previews: PreviewProvider {
    static var previews: some View {
        PlayerCard(name: "Jake", colour: "FF00FF")
            .frame(maxWidth: 180)
    }
}
