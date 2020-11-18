//
//  PlayersView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

class SheetState: Identifiable {
    var editingPlayer: Player?
    var isCreating: Bool
    
    init(editing player: Player?) {
        self.isCreating = player == nil
        self.editingPlayer = player
    }
}

struct PlayersListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Player.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.created, ascending: true)],
        animation: .default)
    private var players: FetchedResults<Player>
    
    @State private var sheetState: SheetState? = nil
    
    var columns: [GridItem] =
        Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(players, id: \.self) { player in
                        PlayerCard(name: player.wrappedName, colour: player.wrappedColor)
                            .contextMenu {
                                Button(action: {
                                    self.deletePlayer(player: player)
                                }) {
                                    HStack {
                                        Text("Delete Player")
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                            .onTapGesture(count: 1, perform: {
                                self.sheetState = SheetState(editing: player)
                            })
                    }
                }
                .padding(35)
            }
            .padding(-20)
            .navigationTitle("Players")
            .toolbar {
                Button(action: {
                    self.sheetState = SheetState(editing: nil)
                }) {
                    Label("Add Player", systemImage: "plus")
                }
            }
            .sheet(item: $sheetState, onDismiss: {
                self.sheetState = nil
            }) { item in
                CreateEditPlayer(onPlayer: onPlayer(name:colour:), editingPlayer: item.editingPlayer)
            }
        }
    }
    
    private func onPlayer(name: String, colour: String) {
        guard let sheetState = self.sheetState else {
            return
        }
        
        do {
            if let player = sheetState.editingPlayer {
                player.name = name
                player.colour = colour
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
            viewContext.delete(player)
            
            try! viewContext.save()
        }
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
