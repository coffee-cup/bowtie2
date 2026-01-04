//
//  CreateGame.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

struct CreateGame: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: UserSettings
    
    @StateObject var createData = PlayerSelectionData()
    
    @FetchRequest(
        entity: Player.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.name, ascending: false)],
        predicate: NSPredicate(format: "hasBeenDeleted == %@", false),
        animation: .default)
    private var players: FetchedResults<Player>

    @FetchRequest(
        entity: Game.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Game.created, ascending: false)])
    private var games: FetchedResults<Game>
    
    @State var isCreatingPlayer = false
    
    @State private var searchText = ""

    private var filteredPlayers: [Player] {
        let base = searchText.isEmpty
            ? Array(players)
            : players.filter { $0.name!.lowercased().contains(searchText.lowercased()) }

        if settings.playerSortOrder == PlayerSortOrder.recentlyUsed.rawValue {
            return base.sorted { p1, p2 in
                switch (p1.lastGameDate, p2.lastGameDate) {
                case let (d1?, d2?): return d1 > d2
                case (nil, _): return false
                case (_, nil): return true
                }
            }
        }
        return base.sorted { ($0.name ?? "").localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
    }

    private var suggestedNames: [String] {
        var nameData: [String: (count: Int, lastUsed: Date, displayName: String)] = [:]

        for game in games {
            let name = game.wrappedName.trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { continue }
            let key = name.lowercased()

            if let existing = nameData[key] {
                nameData[key] = (existing.count + 1, max(existing.lastUsed, game.wrappedCreated), existing.displayName)
            } else {
                nameData[key] = (1, game.wrappedCreated, name)
            }
        }

        let now = Date()
        let scored = nameData.values.map { data -> (String, Double) in
            let daysAgo = now.timeIntervalSince(data.lastUsed) / 86400
            let recencyBonus = max(0, 30 - daysAgo)
            let score = Double(data.count) * 10 + recencyBonus
            return (data.displayName, score)
        }

        return scored
            .sorted { $0.1 > $1.1 }
            .prefix(8)
            .map { $0.0 }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Game Name").padding(.top)) {
                    HStack {
                        TextField("Canasta", text: $createData.name)

                        if !suggestedNames.isEmpty {
                            Menu {
                                ForEach(suggestedNames, id: \.self) { name in
                                    Button(name) { createData.name = name }
                                }
                            } label: {
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.secondary)
                                    .padding(12)
                                    .contentShape(Rectangle())
                            }
                            .padding(-12)
                        }
                    }
                }
                
                Section(header: HStack {
                    Text("Who's playing")
                    
                    Spacer()
                    
                    if players.count > 0 {
                        Button(action: {
                            self.isCreatingPlayer.toggle()
                        }, label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18))
                                .foregroundColor(Color.blue)
                        }).padding(.horizontal)
                    }
                }) {
                    if players.count == 0 {
                        Button(action: {
                            self.isCreatingPlayer.toggle()
                        }) {
                            Text("Create player")
                        }
                    } else {
                        List {
                            ForEach(filteredPlayers, id: \.self) { player in
                                PlayerSelectionItem(colour: player.wrappedColor, name: player.wrappedName, isSelected: self.createData.getSelected(id: player.id))
                            }
                        }.searchable(text: $searchText)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        self.createGame()
                    }
                    .disabled(createData.name == "" || createData.numPlayersAdded == 0)
                }
            }
            .sheet(isPresented: $isCreatingPlayer) {
                CreateEditPlayer(onPlayer: self.addPlayer, editingPlayer: nil)
                    .environmentObject(settings)
            }
            .navigationTitle("Create Game")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func addPlayer(name: String, colour: String) {
        do {
            let player = Player.createPlayer(context: viewContext, name: name, colour: colour)
            
            createData.selectPlayer(id: player.id)
            
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func createGame() {
        do {
            var playerLookup: [ObjectIdentifier:Player] = [:]
            players.forEach({ player in playerLookup[player.id] = player })
            
            let playersToAdd = self.createData.addedPlayers.keys
                .filter({ k in createData.addedPlayers[k] ?? false })
                .map({ k in viewContext.object(with: playerLookup[k]!.objectID) as! Player })
            
            Game.createGameWithPlayers(context: viewContext, name: createData.name, players: playersToAdd)
            
            try viewContext.save()
            
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct CreateGame_Previews: PreviewProvider {
    static var previews: some View {
        CreateGame()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(UserSettings())
    }
}
