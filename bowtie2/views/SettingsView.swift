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
        NavigationView {
            Form {
                Section {
                    Toggle(isOn: $settings.showGraph) {
                        Text("Show graph")
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
                    NavigationLink(destination: AboutView()) {
                        Text("About")
                    }
                    
                    Button(action: {
                        self.openFeedback()
                    }) {
                        Text("Feedback")
                    }
                }
            }
            .sheet(isPresented: $isShowingPremium, content: presentSheet)
            .navigationTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private func presentSheet() -> some View {
        PremiumView().environmentObject(settings)
    }
    
    private func openFeedback() {
        let subject = "Bowtie Feedback"
        let to = "jakerunzer@gmail.com"
        
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let url = URL(string: "mailto:\(to)?subject=\(subjectEncoded)")
    
        if let url = url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserSettings())
    }
}
