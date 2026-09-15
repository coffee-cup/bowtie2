//
//  bowtie2App.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-14.
//

import SwiftUI

@main
struct bowtie2App: App {
    let persistenceController: PersistenceController
    let settings: UserSettings

    init() {
        #if DEBUG && targetEnvironment(simulator)
        if ScreenshotFixture.isEnabled {
            persistenceController = PersistenceController(inMemory: true, cloudSyncEnabled: false)
            ScreenshotFixture.seed(persistenceController.container.viewContext)
            settings = UserSettings()
            settings.showWelcome = false
            settings.showGraph = true
            settings.theme = themes[0]
            settings.playerSortOrder = PlayerSortOrder.alphabetical.rawValue
            settings.liveActivitiesEnabled = false
            return
        }
        #endif
        persistenceController = PersistenceController.shared
        settings = UserSettings(appIcon: UIApplication.shared.alternateIconName ?? "primary")
    }
    
    @State private var showWelcome = false
    
    var body: some Scene {
        WindowGroup {
            AppView()
                #if DEBUG && targetEnvironment(simulator)
                .preferredColorScheme(ScreenshotFixture.colorScheme)
                #endif
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(settings)
                .onReceive(.IAPHelperPurchaseNotification) { notification in
                    guard let productID = notification.object as? String else {
                        return
                    }
                    
                    self.handlePurchaseNotification(productID: productID)
                }
                .sheet(isPresented: $showWelcome, onDismiss: {
                    settings.showWelcome = false
                }) {
                    WelcomeView().environmentObject(settings)
                }
                .onAppear {
                    self.showWelcome = settings.showWelcome
                }
        }
    }
    
    func handlePurchaseNotification(productID: String) {
        if productID == BowtieProducts.Premium {
            settings.hasPremium = true
        }
    }
}
