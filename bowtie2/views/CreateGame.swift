//
//  CreateGame.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

class CreateGameData: ObservableObject {
    @Published var name = ""
    @Published var addedPlayers: [ObjectIdentifier:Bool] = [:]
    @State var numPlayersAdded = 0
    
    func getSelected(id: ObjectIdentifier) -> Binding<Bool> {
        let binding = Binding<Bool>(get: {
            return self.addedPlayers[id] ?? false
        }, set: { newValue in
            self.addedPlayers[id] = newValue
            
            let t = self.addedPlayers.values.reduce(0, { num, v in num + (v ? 1 : 0) })
            self.numPlayersAdded = t
        })
        
        return binding
    }
}

struct PlayerItem: View {
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
        .padding(.vertical, 6)
    }
}

struct CreateGame: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var createData = CreateGameData()
    
    
    @FetchRequest(
        entity: Player.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.created, ascending: true)],
        animation: .default)
    private var players: FetchedResults<Player>
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading){
                    Text("Game Name")
                        .font(.caption)
                        .foregroundColor(Color(.label))
                    
                    TextField("Game", text: $createData.name)
                        .padding(.all)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(4)
                    
                }
                .padding()
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Who's Playing")
                            .font(.caption)
                            .foregroundColor(Color(.label))
                        
                        Spacer()
                        
                        Button(action: {
                            print("add player")
                        }, label: {
                            Image(systemName: "plus")
                        }).padding(.horizontal)
                    }.padding(.horizontal)
                    
                    List {
                        ForEach(players, id: \.self) { player in
                            PlayerItem(colour: player.wrappedColor, name: player.wrappedName, isSelected: self.createData.getSelected(id: player.id))
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                .padding(.vertical)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .navigationBarItems(leading:
                                    Button("Close") {
                                        self.presentationMode.wrappedValue.dismiss()
                                    },
                                trailing:
                                    Button("Create") {
                                        self.createGame()
                                    }.disabled(createData.name == ""))
            .navigationTitle("Create Game")
        }
    }
    
    private func createGame() {
        do {
            var playerLookup: [ObjectIdentifier:Player] = [:]
            players.forEach({ player in playerLookup[player.id] = player })
                
            let playersToAdd = self.createData.addedPlayers.keys
                .filter({ k in createData.addedPlayers[k] ?? false })
                .map({ k in viewContext.object(with: playerLookup[k]!.objectID) as! Player })
            
            let game = Game.createGame(context: viewContext, name: createData.name)

            // Create player scores for each playexzr
            playersToAdd.forEach({ player in
                PlayerScore.createPlayerScore(context: viewContext, game: game, player: player)
            })
            
            try viewContext.save()
            
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct CreateGame_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateGame().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
