//
//  bowtie2App.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-14.
//

import SwiftUI
import Sentry

@main
struct bowtie2App: App {
    let persistenceController = PersistenceController.shared
    let settings = UserSettings(appIcon: UIApplication.shared.alternateIconName ?? "primary")
    
    @State private var showWelcome = false
    
    var body: some Scene {
        WindowGroup {
            AppView()
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
                    self.configureSentry()
                }
        }
    }
    
    func configureSentry() {
        SentrySDK.start { options in
            options.dsn = "https://2a1698cfb0264c09864f8301cc70503f@o372154.ingest.sentry.io/5573188"
//            options.debug = true // Enabled debug when first installing is always helpful
        }
    }
    
    func handlePurchaseNotification(productID: String) {
        if productID == BowtieProducts.Premium {
            settings.hasPremium = true
        }
    }
}
