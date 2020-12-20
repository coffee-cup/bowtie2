//
//  ThemeSelect.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-06.
//

import SwiftUI

fileprivate struct ThemeItemView: View {
    @EnvironmentObject var settings: UserSettings
    
    var theme: Theme
    
    var body: some View {
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
            } else if theme.requiresPremium && !settings.hasPremium {
                Image(systemName: "lock.fill")
                    .foregroundColor(.white)
                    .font(.title2)
                    .padding(.horizontal, 20)
            }
        }
        .background(theme.gradient)
        .frame(maxWidth: .infinity)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct ThemeSelectView: View {
    @EnvironmentObject var settings: UserSettings
    @State var showPremiumView: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                ForEach(themes, id: \.name) { theme in
                    Button(action: {
                        if theme.name == settings.theme.name {
                            return
                        }
                        
                        if !theme.requiresPremium || settings.hasPremium {
                            settings.theme = theme
                        } else {
                            self.showPremiumView = true
                        }
                    }) {
                        ThemeItemView(theme: theme)
                    }
                }
            }
        }
        .navigationTitle("Themes")
        .sheet(isPresented: $showPremiumView, content: {
            PremiumView()
                .environmentObject(settings)
        })
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
