//
//  WelcomeView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-20.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        VStack {
            HStack {
                Text("Welcome to\nBowtie")
                    .font(.system(size: 48, weight: .bold))
                    .gradientForeground(gradient: settings.theme.gradient)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image("cards")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 52, height: 52)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Gather family and friends")
                            .fontWeight(.bold)
                        Text("Get ready to tuck into a card game")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(.secondaryLabel))
                            .lineLimit(nil)
                    }
                    .padding(.leading)
                    Spacer()
                }
                
                HStack {
                    Text("🎲").font(.system(size: 32))
                        .frame(width: 52)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create game")
                            .fontWeight(.bold)
                        Text("Add players with a custom identifiable colour")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(.secondaryLabel))
                            .lineLimit(nil)
                    }
                    .padding(.leading)
                    Spacer()
                }
                
                HStack {
                    Text("📝").font(.system(size: 32))
                        .frame(width: 52)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Record Scores").fontWeight(.bold)
                        Text("After each round enter the score for each player")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(.secondaryLabel))
                            .lineLimit(nil)
                    }
                    .padding(.leading)
                    
                    Spacer()
                }.frame(maxWidth: .infinity)
            }
            .padding(.vertical, 40)
            
            Button(action: {
                self.getStarted()
            }) {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
            }
            .foregroundColor(.white)
            .font(.system(size: 22, weight: .bold))
            .background(settings.theme.gradient)
            .cornerRadius(40)
        }
        .padding(.all)
    }
    
    private func getStarted() {
        settings.showWelcome = false
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(UserSettings())
    }
}
