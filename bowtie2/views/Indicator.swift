//
//  Indicator.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-01.
//

import SwiftUI

struct Indicator: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.secondarySystemFill))
            .frame(
                width: 60,
                height: 6
            )
            .padding(.vertical)
    }
}

struct Indicator_Previews: PreviewProvider {
    static var previews: some View {
        Indicator()
    }
}
