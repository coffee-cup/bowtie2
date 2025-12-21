//
//  GameSettings.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-29.
//

import SwiftUI

struct AddPlayersToGame: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var game: Game
    @StateObject var selectionData = CreateGameData()

    @FetchRequest(
        entity: Player.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.name, ascending: false)],
        predicate: NSPredicate(format: "hasBeenDeleted == %@", false),
        animation: .default)
    private var allPlayers: FetchedResults<Player>

    @State private var searchText = ""
    @State private var showRemoveConfirmation = false

    private var existingPlayerIds: Set<ObjectIdentifier> {
        Set(game.scoresArray.compactMap { $0.player }.map { $0.id })
    }

    private var sortedPlayers: [Player] {
        let existing = allPlayers.filter { existingPlayerIds.contains($0.id) }
        let available = allPlayers.filter { !existingPlayerIds.contains($0.id) }
        let combined = Array(existing) + Array(available)
        if searchText.isEmpty {
            return combined
        }
        return combined.filter { $0.wrappedName.lowercased().contains(searchText.lowercased()) }
    }

    private var playersToAdd: [Player] {
        var playerLookup: [ObjectIdentifier: Player] = [:]
        allPlayers.forEach { playerLookup[$0.id] = $0 }
        return selectionData.addedPlayers.keys
            .filter { id in (selectionData.addedPlayers[id] ?? false) && !existingPlayerIds.contains(id) }
            .compactMap { playerLookup[$0] }
    }

    private var playersToRemove: [Player] {
        var playerLookup: [ObjectIdentifier: Player] = [:]
        allPlayers.forEach { playerLookup[$0.id] = $0 }
        return existingPlayerIds
            .filter { id in !(selectionData.addedPlayers[id] ?? false) }
            .compactMap { playerLookup[$0] }
    }

    private var hasChanges: Bool {
        !playersToAdd.isEmpty || !playersToRemove.isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                if allPlayers.isEmpty {
                    Text("No players available")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(sortedPlayers, id: \.self) { player in
                            PlayerItem(
                                colour: player.wrappedColor,
                                name: player.wrappedName,
                                isSelected: selectionData.getSelected(id: player.id)
                            )
                        }
                    }.searchable(text: $searchText)
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if !playersToRemove.isEmpty {
                        showRemoveConfirmation = true
                    } else {
                        saveChanges()
                    }
                }.disabled(!hasChanges)
            )
            .navigationBarTitle("Players", displayMode: .inline)
            .onAppear {
                for id in existingPlayerIds {
                    selectionData.selectPlayer(id: id)
                }
            }
            .alert("Remove Players?", isPresented: $showRemoveConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    saveChanges()
                }
            } message: {
                Text("Removing players will delete their score history for this game.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func saveChanges() {
        let toAdd = playersToAdd.map { viewContext.object(with: $0.objectID) as! Player }
        let toRemove = playersToRemove.map { viewContext.object(with: $0.objectID) as! Player }

        game.addPlayers(context: viewContext, players: toAdd)
        toRemove.forEach { game.removePlayer(context: viewContext, player: $0) }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        presentationMode.wrappedValue.dismiss()
    }
}

struct GameSettings: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var game: Game
    @State var name = ""
    @State var isAddingPlayers = false

    var body: some View {
        Form {
            Section(header: Text("Game Name")) {
                TextField("Game Name", text: $name, onCommit: {
                    self.saveGame()
                })
            }
            
            Section(header: Text("Winner")) {
                Picker(selection:
                        Binding(
                            get: { game.winnerSort },
                            set: { value in
                                self.game.winnerSort = value
                            }
                        ),
                       label: Text("Winner sort order")) {
                    ForEach(WinnerSort.allCases, id: \.self.rawValue) { value in
                        Text(value.stringValue).tag(value)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text("Players")) {
                HStack {
                    Text("\(game.scoresArray.count) players")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Edit Players") {
                        isAddingPlayers = true
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingPlayers) {
            AddPlayersToGame(game: game)
                .environment(\.managedObjectContext, viewContext)
        }
        .navigationTitle("Game Settings")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .onAppear {
            self.name = game.wrappedName
        }
        .onDisappear {
            self.saveGame()
        }
    }
    
    private func saveGame() {
        do {
            game.name = self.name
            viewContext.refresh(game, mergeChanges: true)
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct GameSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GameSettings(game:
                            Game.gameByName(context: PersistenceController.preview.container.viewContext, name: "Blitz")!)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
