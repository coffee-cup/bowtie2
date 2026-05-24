//
//  AppView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

private enum AppTab: Hashable {
    case games
    case players
    case settings
}

struct AppView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var settings: UserSettings

    @State private var selectedTab: AppTab = .games
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GamesListView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Games")
                }
                .tag(AppTab.games)
            PlayersListView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Players")
                }
                .tag(AppTab.players)
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(AppTab.settings)
        }
        .onChange(of: selectedTab) { tab in
            Task {
                if tab == .games {
                    await LiveActivityManager.shared.restoreGameContext(settingsEnabled: settings.liveActivitiesEnabled)
                } else {
                    await LiveActivityManager.shared.hideGameContext()
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            guard selectedTab == .games else { return }
            switch phase {
            case .active, .background:
                Task {
                    await LiveActivityManager.shared.restoreGameContext(settingsEnabled: settings.liveActivitiesEnabled)
                }
            default:
                break
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .environmentObject(UserSettings())
    }
}
