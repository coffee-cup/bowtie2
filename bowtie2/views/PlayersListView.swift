//
//  PlayersView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI
import CoreData

class PlayersListSheetState: Identifiable {
    var editingPlayer: Player?
    var isCreating: Bool
    
    init(editing player: Player?) {
        self.isCreating = player == nil
        self.editingPlayer = player
    }
}

struct PlayersListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: UserSettings
    
    @FetchRequest(
        entity: Player.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.name, ascending: true)],
        predicate: NSPredicate(format: "hasBeenDeleted == %@", false),
        animation: .default)
    private var players: FetchedResults<Player>
    
    @State private var sheetState: PlayersListSheetState? = nil
    
    var columns: [GridItem] =
        Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        NavigationStack {
            if players.count == 0 {
                VStack {
                    Spacer()
                    
                    VStack {
                        Text("No players yet")
                            .padding(.bottom)
                        
                        Image("cards")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 180.0)
                    }
                    .offset(y: -20)
                    
                    Spacer()
                    
                    Button(action: {
                        self.sheetState = PlayersListSheetState(editing: nil)
                    }) {
                        Text("Create Player")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .bold))
                    .background(settings.theme.gradient)
                    .cornerRadius(40)
                    .padding(.top)
                    
                    Text("Reuse players between games")
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))
                }
                .frame(maxHeight: .infinity)
                .padding(.all)
                .navigationTitle("Games")
                .sheet(item: $sheetState, content: presentSheet)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(players, id: \.self) { player in
                            Button(action: {
                                self.sheetState = PlayersListSheetState(editing: player)
                            }) {
                                PlayerCard(name: player.wrappedName, colour: player.wrappedColor)
                            }
                            .contextMenu {
                                Button("Delete Player", role: .destructive) {
                                    self.deletePlayer(player: player)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal).padding(.bottom)
                .navigationTitle("Players")
                .toolbar {
                    Button(action: {
                        self.sheetState = PlayersListSheetState(editing: nil)
                    }) {
                        Label("Add Player", systemImage: "plus")
                    }
                }
                .sheet(item: $sheetState, content: presentSheet)
            }
        }
    }
    
    @ViewBuilder
    private func presentSheet(for sheet: PlayersListSheetState) -> some View {
        CreateEditPlayer(onPlayer: onPlayer(name:colour:), editingPlayer: sheet.editingPlayer)
    }
    
    private func onPlayer(name: String, colour: String) {
        guard let sheetState = self.sheetState else {
            return
        }
        
        do {
            if let player = sheetState.editingPlayer {
                player.update(context: viewContext, name: name, colour: colour)
            } else {
                Player.createPlayer(context: viewContext, name: name, colour: colour)
            }
            
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deletePlayer(player: Player) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
            if player.scoresArray.count == 0 {
                viewContext.delete(player)
            } else {
                player.hasBeenDeleted = true
            }
            
            try! viewContext.save()
        }
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(UserSettings())
    }
}
