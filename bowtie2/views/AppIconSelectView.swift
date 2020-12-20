//
//  AppIconSelectView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-12.
//

import SwiftUI

struct AppIcon {
    var name: String
    var filename: String
    var requiresPremium: Bool
}

var icons: [AppIcon] = [
    AppIcon(name: "Default", filename: "primary", requiresPremium: false),
    AppIcon(name: "XMas Red", filename: "xmas-red", requiresPremium: true),
]

struct AppIconView: View {
    @EnvironmentObject var settings: UserSettings
    
    @State var icon: AppIcon
    
    var body: some View {
        HStack(spacing: 20) {
            Image(icon.filename)
                .resizable().frame(width: 60, height: 60)
                .cornerRadius(10.5)
            
            Text(icon.name)
                .foregroundColor(.primary)
            
            Spacer()
            
            if settings.appIcon == icon.filename {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.primary)
                    .font(.title)
                    .padding(.horizontal)
            } else if icon.requiresPremium && !settings.hasPremium {
                Image(systemName: "lock.fill")
                    .foregroundColor(.primary)
                    .font(.title2)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.horizontal)
    }
}

struct AppIconSelectView: View {
    @EnvironmentObject var settings: UserSettings
    @State var showPremiumView: Bool = false
    
    var body: some View {
        ScrollView {
            if UIApplication.shared.supportsAlternateIcons {
                ForEach(icons, id: \.name) { icon in
                    Button(action: {
                        if icon.filename == settings.appIcon {
                            return
                        }
                        
                        if !icon.requiresPremium || settings.hasPremium {
                            self.setAppIcon(icon: icon)
                        } else {
                            self.showPremiumView = true
                        }
                    }) {
                        AppIconView(icon: icon)
                    }
                }
                
            } else {
                Text("Alternate app icons not supported")
            }
        }
        .navigationTitle("Themes")
        .sheet(isPresented: $showPremiumView, content: {
            PremiumView()
                .environmentObject(settings)
        })
    }
    
    private func setAppIcon(icon: AppIcon) {
        let altName = icon.filename == "primary" ? nil : icon.filename
        UIApplication.shared.setAlternateIconName(altName) { error in
            if error == nil {
                settings.appIcon = icon.filename
            }
        }
    }
}

struct AppIconSelectView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconSelectView()
            .environmentObject(UserSettings())
    }
}
