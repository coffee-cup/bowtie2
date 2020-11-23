//
//  View.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-22.
//

import SwiftUI

extension View {
    public func gradientForeground(gradient: Gradient) -> some View {
        self.overlay(LinearGradient(gradient: gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing))
            .mask(self)
    }
    
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
