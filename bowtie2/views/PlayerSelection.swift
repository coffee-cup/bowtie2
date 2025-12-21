//
//  PlayerSelection.swift
//  bowtie2
//

import SwiftUI

class PlayerSelectionData: ObservableObject {
    @Published var name = ""
    @Published var addedPlayers: [ObjectIdentifier:Bool] = [:]

    func getSelected(id: ObjectIdentifier) -> Binding<Bool> {
        let binding = Binding<Bool>(get: {
            return self.addedPlayers[id] ?? false
        }, set: { newValue in
            self.addedPlayers[id] = newValue
        })

        return binding
    }

    func selectPlayer(id: ObjectIdentifier) {
        self.addedPlayers[id] = true
    }

    var numPlayersAdded: Int {
        addedPlayers.values.reduce(0, { num, v in num + (v ? 1 : 0) })
    }
}

struct PlayerSelectionItem: View {
    var colour: String
    var name: String

    @Binding var isSelected: Bool

    var body: some View {
        HStack(spacing: 20) {
            Toggle(isOn: $isSelected) {
                Text("Include player \(name)")
            }
            .labelsHidden()

            Text(name)

            Spacer()

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: colour))
                .frame(width: 32, height: 32)
        }
        .padding(.vertical, 2)
    }
}
