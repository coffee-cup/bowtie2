//
//  EnterScoreView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-22.
//

import SwiftUI

struct CalcButton: View {
    var text: String
    var onTap: () -> ()
    
    var body: some View {
        Button(action: {
            self.onTap()
        }) {
            Text(text)
                .foregroundColor(.primary)
                .font(.system(size: 22))
        }
        .padding(.vertical, 22)
    }
}

struct EnterScoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var playerScore: PlayerScore
    
    @State var score: Int = 0
    let addScore: ((_ playerScore: PlayerScore, _ score: Int) -> ())?
    
    var columns: [GridItem] =
        Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Enter score for \(playerScore.player?.wrappedName ?? "No name"    )")
                    .font(.callout)
                    .padding(.top, 32)
                
                Text("\(score)")
                    .font(.system(size: 160, weight: .bold))
                    .padding(.vertical)
                    .lineLimit(1)
                
                LazyVGrid(columns: columns) {
                    CalcButton(text: "1", onTap: { self.addValue(digit: 1)})
                    CalcButton(text: "2", onTap: { self.addValue(digit: 2)})
                    CalcButton(text: "3", onTap: { self.addValue(digit: 3)})
                    CalcButton(text: "4", onTap: { self.addValue(digit: 4)})
                    CalcButton(text: "5", onTap: { self.addValue(digit: 5)})
                    CalcButton(text: "6", onTap: { self.addValue(digit: 6)})
                    CalcButton(text: "7", onTap: { self.addValue(digit: 7)})
                    CalcButton(text: "8", onTap: { self.addValue(digit: 8)})
                    CalcButton(text: "9", onTap: { self.addValue(digit: 9)})
                }
                LazyVGrid(columns: columns) {
                    Spacer()
                    CalcButton(text: "0", onTap: { self.addValue(digit: 0)})
                    CalcButton(text: "<", onTap: { self.deleteValue() })
                }
                .padding(.bottom)
                
                Spacer(minLength: 20)
                
                Button(action: {
                    if let addScore = self.addScore {
                        addScore(playerScore, score)
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("add score")
                        .foregroundColor(Color.white)
                }
                .font(.system(size: 22))
                .frame(maxWidth: .infinity)
                .padding(.all)
                .background(Color.primary)
                .cornerRadius(40)
                .padding(.all)
            }
        }
    }
    
    private func addValue (digit: Int) {
        score = score.addDigit(digit: digit)
    }
    
    private func deleteValue () {
        score = score.removeDigit()
    }
}

struct EnterScoreView_Previews: PreviewProvider {
    static var previews: some View {
        EnterScoreView(playerScore: PlayerScore.scoresForGame(context: PersistenceController.preview.container.viewContext, name: "Blitz")[0], addScore: nil)
    }
}
