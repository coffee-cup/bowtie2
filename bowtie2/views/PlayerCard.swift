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
                    .foregroundColor(Color.white)
            }
            .padding(.all)
        }
        .frame(height: 100)
        .cornerRadius(24)
//        .shadow(color: Color(hex: colour), radius: 4)
    }
}

struct PlayerCard_Previews: PreviewProvider {
    static var previews: some View {
        PlayerCard(name: "Jake", colour: "FF00FF")
            .frame(maxWidth: 180)
    }
}
