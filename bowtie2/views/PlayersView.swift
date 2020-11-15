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
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
