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
}

var icons: [AppIcon] = [
    AppIcon(name: "Default", filename: "primary"),
    AppIcon(name: "XMas Red", filename: "xmas-red")
]

struct AppIconSelectView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        ScrollView {
            if UIApplication.shared.supportsAlternateIcons {
                
                ForEach(icons, id: \.name) { icon in
                    Button(action: {
                        self.setAppIcon(icon: icon)
                    }) {
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
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
            } else {
                Text("Alternate app icons not supported")
            }
        }.navigationTitle("Themes")
        
        
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
