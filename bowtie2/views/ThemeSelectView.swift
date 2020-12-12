//
//  ThemeSelect.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-06.
//

import SwiftUI

struct ThemeSelectView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        ScrollView {
            ForEach(themes, id: \.name) { theme in
                Button(action: {
                    settings.theme = theme
                }) {
                    HStack {
                        Text("\(theme.name)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.all)
                        
                        Spacer()
                        
                        if settings.theme.name == theme.name {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding(.horizontal)
                        }
                    }
                    .background(theme.gradient)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Themes")
    }
}

struct ThemeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ThemeSelectView()
                .environmentObject(UserSettings())
        }
    }
}
