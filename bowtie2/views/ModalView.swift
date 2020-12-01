//
//  ModalView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-01.
//

import SwiftUI

struct ModalView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Indicator()
                .padding(.top)
            
            self.content
        }
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView() {
            Text("Hello")
        }
    }
}
