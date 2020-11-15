//
//  CreateEditPlayer.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

struct PlayerWheel: View {
    @Binding var colour: Color
    var boundingSize: CGFloat = 140.0
    
    var body: some View {
        VStack {
            ColorPicker("Choose color for player", selection: $colour, supportsOpacity: false)
                .scaleEffect(CGSize(width: 4, height: 4))
                .labelsHidden()
                .position(x: boundingSize / 2, y: boundingSize / 2)
        }
        .frame(width: boundingSize, height: boundingSize)
    }
}

struct CreateEditPlayer: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var editPlayer: Player?
    
    @State private var name: String = ""
    @State private var colour: Color = Color(hex: "FF1493")
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    PlayerWheel(colour: $colour)
                        .padding(.bottom)
                    
                    TextField("Player name", text: $name)
                        .padding(.all)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                }
                .padding(.vertical, 20)
                
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Create Player")
            .navigationBarItems(leading:
                                    Button("Close") {
                                        self.presentationMode.wrappedValue.dismiss()
                                    },
                                trailing:
                                    Button("Create") {
                                        self.addPlayer()
                                    }.disabled(name == ""))
        }
    }
    
    private func addPlayer() {
        let newPlayer = Player(context: viewContext)
        newPlayer.name = name
        newPlayer.colour = colour.toHex(alpha: false)
        
        do {
            try viewContext.save()
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct CreateEditPlayer_Previews: PreviewProvider {
    static var previews: some View {
        CreateEditPlayer().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        
        CreateEditPlayer().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
