//
//  AboutView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-13.
//

import SwiftUI

struct VersionView: View {
    @EnvironmentObject var settings: UserSettings
    
    var version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("primary")
                .resizable()
                .frame(width: 160, height: 160)
                .cornerRadius(10)
                .padding(.bottom)
            
            Text("Bowtie").fontWeight(.bold)
            Text("Version \(version ?? "unknown")")
                .font(.caption)
                .foregroundColor(Color(.secondaryLabel))
                .padding(.top, 1)
            
            Spacer()
            
            Link("Made with ♥️ by Jake", destination: URL(string: "https://jakerunzer.com?ref=bowtie")!)
                .font(.system(size: 14))
                .gradientForeground(gradient: settings.theme.gradient)
//                .foregroundColor(.primary)
                .padding()
        }
    }
}

struct VersionView_Previews: PreviewProvider {
    static var previews: some View {
        VersionView()
            .environmentObject(UserSettings())
    }
}
