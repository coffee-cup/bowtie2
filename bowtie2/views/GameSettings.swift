//
//  GameSettings.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-29.
//

import SwiftUI

struct AddPlayersToGame: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: UserSettings

    @ObservedObject var game: Game
    @StateObject var selectionData = PlayerSelectionData()

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
        let sortPlayers: ([Player]) -> [Player] = { players in
            if settings.playerSortOrder == PlayerSortOrder.recentlyUsed.rawValue {
                return players.sorted { p1, p2 in
                    switch (p1.lastGameDate, p2.lastGameDate) {
                    case let (d1?, d2?): return d1 > d2
                    case (nil, _): return false
                    case (_, nil): return true
                    }
                }
            }
            return players.sorted { ($0.name ?? "").localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
        }
        let existing = sortPlayers(allPlayers.filter { existingPlayerIds.contains($0.id) })
        let available = sortPlayers(allPlayers.filter { !existingPlayerIds.contains($0.id) })
        let combined = existing + available
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
        NavigationStack {
            Form {
                if allPlayers.isEmpty {
                    Text("No players available")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(sortedPlayers, id: \.self) { player in
                            PlayerSelectionItem(
                                colour: player.wrappedColor,
                                name: player.wrappedName,
                                isSelected: selectionData.getSelected(id: player.id)
                            )
                        }
                    }.searchable(text: $searchText)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !playersToRemove.isEmpty {
                            showRemoveConfirmation = true
                        } else {
                            saveChanges()
                        }
                    }
                    .disabled(!hasChanges)
                }
            }
            .navigationTitle("Players")
            .navigationBarTitleDisplayMode(.inline)
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

        dismiss()
    }
}

struct GameSettings: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: UserSettings

    @ObservedObject var game: Game
    @State var name = ""
    @State var isAddingPlayers = false

    var body: some View {
        Form {
            Section {
                TextField("Game Name", text: $name, onCommit: {
                    self.saveGame()
                })
            }

            Section("Players") {
                HStack {
                    Text("\(game.scoresArray.count) players")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Edit") {
                        isAddingPlayers = true
                    }
                }
            }

            Section("Scoring") {
                Picker(selection:
                        Binding(
                            get: { game.winnerSort },
                            set: { value in
                                self.game.winnerSort = value
                            }
                        ),
                       label: Text("Winner has")) {
                    ForEach(WinnerSort.allCases, id: \.self.rawValue) { value in
                        Text(value.stringValue).tag(value)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section("Display") {
                Toggle(isOn: Binding(
                    get: { game.keepScreenAwake },
                    set: { game.keepScreenAwake = $0 }
                )) {
                    Text("Keep Screen Awake")
                }

                if LiveActivityManager.shared.isSupported && settings.liveActivitiesEnabled {
                    Toggle(isOn: Binding(
                        get: { game.liveActivityEnabled },
                        set: { newValue in
                            game.liveActivityEnabled = newValue
                            Task {
                                if newValue {
                                    try? await LiveActivityManager.shared.start(game: game)
                                } else {
                                    await LiveActivityManager.shared.end()
                                }
                            }
                        }
                    )) {
                        Text("Live Activity")
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingPlayers) {
            AddPlayersToGame(game: game)
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(settings)
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
            GameSettings(
                game: Game.gameByName(context: PersistenceController.preview.container.viewContext, name: "Blitz")!
            )
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(UserSettings())
        }
    }
}
