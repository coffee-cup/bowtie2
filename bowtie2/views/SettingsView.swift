//
//  SettingsView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-06.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: UserSettings
    
    @State var isShowingPremium = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $settings.showGraph) {
                        Text("Show graph")
                    }

                    Picker("Player sort", selection: $settings.playerSortOrder) {
                        ForEach(PlayerSortOrder.allCases, id: \.rawValue) { order in
                            Text(order.displayName).tag(order.rawValue)
                        }
                    }
                }
                
                Section {
                    NavigationLink(destination: ThemeSelectView()) {
                        HStack {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(settings.theme.gradient)
                                .frame(width: 28, height: 28)
                            
                            Text("Theme")
                        }
                    }
                    
                    NavigationLink(destination: AppIconSelectView()) {
                        Text("App icon")
                    }
                }
                
                Section {
                    Button(action: {
                        self.isShowingPremium = true
                    }) {
                        HStack {
                            Text("✨ Premium ✨")
                        }
                    }
                }
                
                Section {
                    Link("About", destination: URL(string: "https://bowtie.cards/about?ref=bowtie")!)
                    
                    Link("Feedback", destination: URL(string: "https://bowtie.cards/feedback?ref=bowtie")!)
                    
                    NavigationLink(destination: VersionView()) {
                        Text("Version")
                    }
                }
            }
            .sheet(isPresented: $isShowingPremium, content: presentSheet)
            .navigationTitle("Settings")
        }
    }
    
    @ViewBuilder
    private func presentSheet() -> some View {
        PremiumView().environmentObject(settings)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserSettings())
    }
}
