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
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(players, id: \.self) { player in
                        Text(player.name!)
                    }
                }
                
                Button(action: {
                    self.showingCreatePlayer.toggle()
                }) {
                    Text("Create Player")
                }
            }
            .navigationTitle("Players")
            .sheet(isPresented: $showingCreatePlayer) {
                CreateEditPlayer()
            }
        }
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
