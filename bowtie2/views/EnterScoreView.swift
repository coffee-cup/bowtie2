//
//  EnterScoreView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-22.
//

import SwiftUI

struct CalcButton: View {
    var text: String
    var accessibilityLabel: String?
    var accessibilityIdentifier: String
    var onTap: () -> ()

    init(
        text: String,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        onTap: @escaping () -> ()
    ) {
        self.text = text
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityIdentifier = accessibilityIdentifier ?? "score.key.\(text)"
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            self.onTap()
        }) {
            Text(text)
                .foregroundColor(.primary)
                .font(.system(size: 22))
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityLabel(accessibilityLabel ?? text)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

struct ScoreActionButton: View {
    let title: String
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 44, height: 44)
                .padding()
                .background(settings.theme.gradient)
                .clipShape(Circle())
                .opacity(isDisabled ? 0.35 : 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .disabled(isDisabled)
        .accessibilityLabel(title)
    }

    @EnvironmentObject private var settings: UserSettings
}

struct ScoreView: View {
    var score: Int
    @Binding var isNegative: Bool
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        ZStack {
            Text(String(score))
                .font(.system(size: 140, weight: .bold))
                .padding(.vertical)
                .gradientForeground(gradient: settings.theme.gradient)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.leading, 70)
            
            HStack {
                Button(action: {
                    isNegative.toggle()
                }) {
                    Text("-")
                        .font(.system(size: 140, weight: .bold))
                        .if(isNegative) { $0.gradientForeground(gradient: settings.theme.gradient) }
                        .if(!isNegative) { $0.foregroundColor(Color(.tertiarySystemFill)) }
                }
                Spacer()
            }
        }
    }
}

struct EnterScoreView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: UserSettings
    
    @ObservedObject var playerScore: PlayerScore
    
    @State var score: Int = 0
    @State var isNegative = false
    @State private var isShowingCalculator = false
    let addScore: ((_ playerScore: PlayerScore, _ score: Int) -> ())?
    
    var columns: [GridItem] =
        Array(repeating: .init(.flexible(), spacing: 0), count: 3)
    
    var body: some View {
        NavigationStack {
            VStack {
                ScoreView(score: score, isNegative: $isNegative)
                
                VStack(spacing: 0) {
                    LazyVGrid(columns: columns, spacing: 0) {
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
                    LazyVGrid(columns: columns, spacing: 0) {
                        Button(action: {
                            self.deleteValue()
                        }) {
                            Image(systemName: "delete.left")
                                .foregroundColor(.primary)
                                .font(.system(size: 24))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        CalcButton(text: "0", onTap: { self.addValue(digit: 0)})
                        
                        ScoreActionButton(title: "Go") {
                            if let addScore = self.addScore {
                                addScore(playerScore, (isNegative ? -1 : 1) * score)
                            }
                            dismiss()
                        }
                    }
                    .padding(.bottom)
                }
                
                Spacer(minLength: 20)
            }
            .navigationTitle("Enter Score for \(playerScore.player?.wrappedName ?? "No Name")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingCalculator = true
                    } label: {
                        Label("Calculator", systemImage: "plus.forwardslash.minus")
                    }
                }
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
        }
        .sheet(isPresented: $isShowingCalculator) {
            ScoreCalculatorView(initialValue: signedScore) { result in
                applyCalculatorResult(result)
            }
            .environmentObject(settings)
        }
    }
    
    private func addValue (digit: Int) {
        score = score.addDigit(digit: digit)
    }
    
    private func deleteValue () {
        score = score.removeDigit()
    }
    
    private func clearScore() {
        score = 0
    }

    private var signedScore: Int {
        isNegative ? -score : score
    }

    private func applyCalculatorResult(_ result: Int) {
        guard result != .min else { return }
        isNegative = result < 0
        score = abs(result)
    }
}

struct EnterScoreView_Previews: PreviewProvider {
    static var previews: some View {
        EnterScoreView(playerScore: PlayerScore.scoresForGame(context: PersistenceController.preview.container.viewContext, name: "Blitz")[0], addScore: nil)
            .environmentObject(UserSettings())
    }
}
