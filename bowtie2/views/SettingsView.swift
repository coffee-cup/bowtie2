//
//  SettingsView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-06.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(isOn: $settings.showGraph) {
                        Text("Show graph")
                    }
                }
                
                Section {
                    NavigationLink(destination:Text("hello")) {
                        HStack {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(LinearGradient(gradient: primaryGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 20, height: 20)
                            
                            Text("Theme")
                        }
                    }
                    
                    NavigationLink(destination:Text("hello")) {
                        Text("App icon")
                    }
                }
                
                Section {
                    NavigationLink(destination:Text("hello")) {
                        Text("About")
                    }
                }
                
                Section {
                    Button(action: {
                        print("Premium")
                    }) {
                        Text("Get Premium")
                    }
                    
                    Button(action: {
                        print("boop")
                    }) {
                        Text("Restore purchase")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
