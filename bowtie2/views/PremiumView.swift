//
//  PremiumView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-13.
//

import SwiftUI
import StoreKit

struct PremiumView: View {
    @EnvironmentObject var settings: UserSettings
    
    @State private var price = "$2.99"
    @State private var product: SKProduct?
    
    var body: some View {
        ZStack {
            if settings.hasPremium {
                ConfettiView( confetti: [
                    .text("🎉"),
                    .text("✨")
                ])
            }
            
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
                
                if settings.hasPremium {
                    Text("Thanks for supporting Bowtie!")
                        .font(.system(size: 22, weight: .bold))
                        .multilineTextAlignment(.center)
                        .gradientForeground(gradient: settings.theme.gradient)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                } else if IAPHelper.canMakePayments() {
                    Button(action: {
                        self.purchase()
                    }) {
                        Text("Get Premium")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .bold))
                    .background(settings.theme.gradient)
                    .cornerRadius(40)
                    
                    Text("One time payment of \(price)")
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Not Available")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .foregroundColor((Color(.secondaryLabel)))
                }
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
                                    self.restore()
                                })
    }
    
    private func purchase() {
        guard let premium = self.product else {
            return
        }
        
        BowtieProducts.store.buyProduct(premium)
    }
    
    private func restore() {
        BowtieProducts.store.restorePurchases()
    }
    
    private func loadProducts() {
        BowtieProducts.store.requestProducts { success, products in
            guard let products = products else {
                return
            }
            
            guard let premium = products.first(where: { p in
                p.productIdentifier == BowtieProducts.Premium
            }) else {
                return
            }
            
            self.product = premium
            self.price = premium.localizedPrice
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
