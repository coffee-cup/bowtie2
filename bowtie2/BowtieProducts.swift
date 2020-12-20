//
//  Constants.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-13.
//

import Foundation

public struct BowtieProducts {
    public static let Premium = "com.jakerunzer.bowtie2.premium"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [BowtieProducts.Premium]
    
    public static let store = IAPHelper(productIds: BowtieProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
