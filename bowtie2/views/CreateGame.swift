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
        .padding(.vertical, 2)
    }
}

struct CreateGame: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: UserSettings
    
    @ObservedObject var createData = CreateGameData()
    
    @FetchRequest(
        entity: Player.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.name, ascending: false)],
        predicate: NSPredicate(format: "hasBeenDeleted == %@", false),
        animation: .default)
    private var players: FetchedResults<Player>
    
    @State var isCreatingPlayer = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Name").padding(.top)) {
                    TextField("Canasta", text: $createData.name)
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
                            ForEach(players, id: \.self) { player in
                                PlayerItem(colour: player.wrappedColor, name: player.wrappedName, isSelected: self.createData.getSelected(id: player.id))
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .navigationBarItems(leading:
                                    Button("Close") {
                                        self.presentationMode.wrappedValue.dismiss()
                                    },
                                trailing:
                                    Button("Create") {
                                        self.createGame()
                                    }.disabled(createData.name == "" || createData.numPlayersAdded == 0))
            .sheet(isPresented: $isCreatingPlayer) {
                CreateEditPlayer(onPlayer: self.addPlayer, editingPlayer: nil)
                    .environmentObject(settings)
            }
            .navigationBarTitle("Create Game", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
