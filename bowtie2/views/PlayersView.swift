//
//  PlayersView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

struct PlayersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Player.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.created, ascending: true)],
        animation: .default)
    private var players: FetchedResults<Player>
    
    @State var showingCreatePlayer = false
    
    var columns: [GridItem] =
        Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        NavigationView {
        
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(players, id: \.self) { player in
                        PlayerCard(name: player.name!, colour: player.colour!)
                            .contextMenu {
                                Button(action: {
                                    self.deletePlayer(player: player)
                                }) {
                                    Text("Delete Player")
                                }
                            }
                    }
                }
                .padding(35)
            }
            .padding(-20)
            .navigationTitle("Players")
            .sheet(isPresented: $showingCreatePlayer) {
                CreateEditPlayer()
            }
            .toolbar {
                Button(action: {
                    self.showingCreatePlayer.toggle()
                }) {
                    Label("Add Player", systemImage: "plus")
                }
            }
        }
    }
    
    private func deletePlayer(player: Player) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
            viewContext.delete(player)
            
            try! viewContext.save()
        }
        
//        withAnimation {
//            do {
//                offsets.map { players[$0] }.forEach(viewContext.delete)
//
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
