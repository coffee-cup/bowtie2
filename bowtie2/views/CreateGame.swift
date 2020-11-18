//
//  CreateGame.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

struct CreateGame: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Player.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.created, ascending: true)],
        animation: .default)
    private var players: FetchedResults<Player>
    
    @State private var name: String = ""
    @State private var isOn = true
    
//    @State var includedPlayers: [String: Bool] {
//        get {
//            
//        }
//    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading){
                    Text("Game Name")
                        .font(.caption)
                        .foregroundColor(Color(.label))
                    
                    TextField("Game", text: $name)
                        .padding(.all)
                        .background(Color(.systemGray6))
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
                            HStack(spacing: 20) {
                                Toggle(isOn: $isOn) {
                                    Text("Include player \(player.wrappedName)")
                                }
                                .labelsHidden()
                                
                                Text(player.wrappedName)
                                
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(hex: player.wrappedColor))
                                    .frame(width: 32, height: 32)
                            }
                            .padding(.vertical, 6)
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
                                        print("Create")
                                    }.disabled(name == ""))
            .navigationTitle("Create Game")
        }
    }
}

struct CreateGame_Previews: PreviewProvider {
    static var previews: some View {
        CreateGame().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
