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
                .scaleEffect(CGSize(width: 5, height: 5))
                .labelsHidden()
                .position(x: boundingSize / 2, y: boundingSize / 2)
        }
        .frame(width: boundingSize, height: boundingSize)
    }
}

struct CreateEditPlayer: View {
    @Environment(\.presentationMode) var presentationMode
    
    let onPlayer: ((_ name: String, _ colour: String) -> ())?
    let editingPlayer: Player?
    
    @State private var title: String = "Create Player"
    @State private var name: String = ""
    @State private var createText: String = "Create"
    @State private var colour: Color = Color(hex: "FF1493")
    
    var body: some View {
        ModalView {
            NavigationView {
                VStack {
                    VStack {
                        PlayerWheel(colour: $colour)
                            .padding(.bottom)
                        
                        TextField("Player name", text: $name)
                            .padding(.all)
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .background(Color(.tertiarySystemFill))
                            .cornerRadius(10)
                    }
                    .padding(.vertical, 20)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .navigationTitle(title)
                .navigationBarItems(leading:
                                        Button("Close") {
                                            self.presentationMode.wrappedValue.dismiss()
                                        },
                                    trailing:
                                        Button(createText) {
                                            if let onPlayer = onPlayer {
                                                onPlayer(name, colour.toHex(alpha: false))
                                            }
                                            self.presentationMode.wrappedValue.dismiss()
                                        }.disabled(name == ""))
                .onAppear(perform: {
                    if let player = editingPlayer {
                        title = "Edit Player"
                        createText = "Save"
                        name = player.name!
                        colour = Color(hex: player.colour!)
                    }
                })
            }
        }
    }
}

struct CreateEditPlayer_Previews: PreviewProvider {
    static var previews: some View {
        CreateEditPlayer(onPlayer: nil, editingPlayer: nil)
        
    }
}
