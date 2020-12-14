//
//  PremiumView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-13.
//

import SwiftUI

struct PremiumView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("✨").font(.system(size: 80))
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("💅").font(.system(size: 32))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Cosmetic Customization")
                                .fontWeight(.bold)
                            Text("Additional themes and app icons")
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.system(size: 14))
                                .foregroundColor(Color(.secondaryLabel))
                                .lineLimit(nil)
                        }
                        .padding(.leading)
                    }
                    HStack {
                        Text("♥️").font(.system(size: 32))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Support").fontWeight(.bold)
                            Text("Support the developer and show appreciation of the app")
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.system(size: 14))
                                .foregroundColor(Color(.secondaryLabel))
                                .lineLimit(nil)
                        }
                        .padding(.leading)
                    }
                }
                .padding(.vertical, 40)
                
                Spacer()
                
                Button(action: {
                    print("purchase")
                }) {
                    Text("Purchase")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                }
                .foregroundColor(.white)
                .font(.system(size: 22, weight: .bold))
                .background(settings.theme.gradient)
                .cornerRadius(40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
        }
        .onAppear {
            self.loadProducts()
        }
        .navigationTitle("Bowtie Premium")
        .navigationBarItems(trailing:
                                Button("Restore") {
                                    print("restore!")
                                })
    }
    
    private func loadProducts() {
        BowtieProducts.store.requestProducts { success, products in
            if success {
              print("PRODUCTS")
              print(products)
            }
        }
    }
}

struct PremiumView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PremiumView()
                .environmentObject(UserSettings())
        }
    }
}
