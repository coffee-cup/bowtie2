//
//  AppView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

struct AppView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView {
            GamesListView().tabItem {
                Image(systemName: "house.fill")
                Text("Games")
            }
            PlayersListView().tabItem {
                Image(systemName: "person.2.fill")
                Text("Players")
            }
            SettingsView().tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
