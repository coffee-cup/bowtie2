//
//  GameView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-21.
//

import SwiftUI
import UIKit
import CoreData

fileprivate class GameViewSheetState: Identifiable {
    var addingScore: PlayerScore?
    var playerHistory: PlayerScore?
    
    init(adding addingScore: PlayerScore?,
         history playerHistory: PlayerScore?) {
        self.addingScore = addingScore
        self.playerHistory = playerHistory
    }
    
    static func addingScore(for player: PlayerScore) -> GameViewSheetState {
        return GameViewSheetState.init(adding: player, history: nil)
    }
    
    static func viewHistory(for player: PlayerScore) -> GameViewSheetState {
        return GameViewSheetState.init(adding: nil, history: player)
    }
}

struct GameView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: UserSettings

    @ObservedObject var game: Game
    @FetchRequest private var playerScores: FetchedResults<PlayerScore>
    @State private var sheetState: GameViewSheetState? = nil
    @State private var orderDraft: [PlayerScore] = []
    @State private var isReordering = false
    @State private var showOrderError = false

    init(game: Game) {
        self.game = game
        _playerScores = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \PlayerScore.manualPosition, ascending: true)],
            predicate: NSPredicate(format: "game == %@", game)
        )
    }

    private var displayedScores: [PlayerScore] {
        game.displayScores(from: Array(playerScores))
    }

    var body: some View {
        Group {
            if isReordering {
                PlayerOrderList(scores: $orderDraft)
            } else {
                scoreboard
            }
        }
        .navigationBarTitle(game.wrappedName, displayMode: .large)
        .navigationBarBackButtonHidden(isReordering)
        .toolbar {
            if isReordering {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isReordering = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveOrder() }
                        .accessibilityIdentifier("playerOrder.save")
                }
            } else {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if game.playerOrder == .manual {
                        Button("Reorder Players", systemImage: "arrow.up.arrow.down") {
                            orderDraft = game.initialPlayerOrder
                            isReordering = true
                        }
                        .disabled(displayedScores.count < 2)
                        .accessibilityIdentifier("playerOrder.reorder")
                    }

                    NavigationLink(destination: GameSettings(game: game)) {
                        Label("Game settings", systemImage: "gearshape")
                    }
                    .accessibilityIdentifier("game.settings")
                }
            }
        }
        .alert("Couldn't Save Player Order", isPresented: $showOrderError) {
            Button("Retry") { saveOrder() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Your saved order hasn't changed. Try saving again.")
        }
        .sheet(item: $sheetState, content: presentSheet)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = game.keepScreenAwake
            startLiveActivityIfNeeded()
        }
        .onDisappear {
            isReordering = false
            orderDraft = []
            showOrderError = false
        }
        .onChange(of: game.keepScreenAwake) { newValue in
            UIApplication.shared.isIdleTimerDisabled = newValue
        }
        .onChange(of: Set(playerScores.filter { !$0.isDeleted && $0.player != nil }.map(\.objectID))) { _ in
            if isReordering {
                self.orderDraft = game.reconciledPlayerOrder(orderDraft.map(\.objectID))
            }
        }
        .onChange(of: settings.liveActivitiesEnabled) { _ in
            startLiveActivityIfNeeded()
        }
        .onChange(of: game.liveActivityEnabled) { _ in
            startLiveActivityIfNeeded()
        }
    }

    private var scoreboard: some View {
        ScrollView {
            ForEach(displayedScores, id: \.objectID) { score in
                Button(action: {
                    sheetState = GameViewSheetState.addingScore(for: score)
                }) {
                    PlayerScoreCard(name: score.player?.wrappedName ?? "",
                                    colour: score.player?.wrappedColor ?? "000000",
                                    score: score.currentScore,
                                    numTurns: score.wrappedHistory.count,
                                    maxScoresGame: game.maxNumberOfEntries)
                }
                .accessibilityIdentifier("scorePlayer.\(score.player?.wrappedName ?? "")")
                .contextMenu {
                    Button(action: {
                        sheetState = GameViewSheetState.viewHistory(for: score)
                    }) {
                        HStack {
                            Text("View History")
                            Image(systemName: "archivebox")
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            if settings.showGraph && game.maxNumberOfEntries >= 2 {
                GameGraph(game: game)
                    .frame(maxWidth: .infinity, idealHeight: 200)
                    .padding(.horizontal)
            } else {
                EmptyView()
            }
        }
    }

    private func saveOrder() {
        guard isReordering else { return }
        do {
            try game.savePlayerOrder(.manual, draft: orderDraft.map(\.objectID))
            isReordering = false
        } catch {
            showOrderError = true
        }
    }
    
    @ViewBuilder
    private func presentSheet(for sheet: GameViewSheetState) -> some View {
        if let addingScore = sheet.addingScore {
            EnterScoreView(playerScore: addingScore, addScore: addScore)
                .environmentObject(settings)
        } else if let playerHistory = sheet.playerHistory {
            ScoreHistoryView(playerScore: playerHistory)
        }
    }
    
    private func startLiveActivityIfNeeded() {
        Task {
            await LiveActivityManager.shared.activateGameContext(game: game, settingsEnabled: settings.liveActivitiesEnabled)
        }
    }

    private func addScore(playerScore: PlayerScore, score: Int) {
        do {
            let currentPlayerScore = viewContext.object(with: playerScore.objectID) as! PlayerScore

            if currentPlayerScore.history == nil {
                currentPlayerScore.history = []
            }

            currentPlayerScore.history?.append(score)

            viewContext.refresh(currentPlayerScore, mergeChanges: true)
            viewContext.refresh(currentPlayerScore.game!, mergeChanges: true)
            viewContext.refresh(currentPlayerScore.player!, mergeChanges: true)

            try viewContext.save()

            if settings.liveActivitiesEnabled && game.liveActivityEnabled {
                Task {
                    await LiveActivityManager.shared.update(game: game)
                }
            }
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

private struct PlayerOrderList: UIViewControllerRepresentable {
    @Binding var scores: [PlayerScore]

    func makeUIViewController(context: Context) -> PlayerOrderController {
        PlayerOrderController(scores: $scores)
    }

    func updateUIViewController(_ controller: PlayerOrderController, context: Context) {
        controller.update(scores: $scores)
    }
}

private final class PlayerOrderController: UITableViewController {
    private var draft: Binding<[PlayerScore]>
    private var scores: [PlayerScore]

    init(scores: Binding<[PlayerScore]>) {
        draft = scores
        self.scores = scores.wrappedValue
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "player")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 58
        tableView.accessibilityIdentifier = "playerOrder.list"
        setEditing(true, animated: false)
    }

    func update(scores: Binding<[PlayerScore]>) {
        draft = scores
        guard self.scores.map(\.objectID) != scores.wrappedValue.map(\.objectID) else { return }
        self.scores = scores.wrappedValue
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        scores.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "player", for: indexPath)
        let score = scores[indexPath.row]
        cell.contentConfiguration = UIHostingConfiguration {
            PlayerOrderRow(score: score)
        }
        cell.selectionStyle = .none
        cell.showsReorderControl = true
        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, moveRowAt source: IndexPath, to destination: IndexPath) {
        let moved = scores.remove(at: source.row)
        scores.insert(moved, at: destination.row)
        // UIKit already moved the row. Publish the draft without reloading the table.
        draft.wrappedValue = scores
    }
}

private struct PlayerOrderRow: View {
    @ObservedObject var score: PlayerScore

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: score.player?.wrappedColor ?? "000000"))
                .frame(width: 16, height: 16)
                .accessibilityHidden(true)
            Text(score.player?.wrappedName ?? "")
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Text(score.currentScore, format: .number)
                .monospacedDigit()
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("reorderPlayer.\(score.player?.wrappedName ?? "")")
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            GameView(game: Game.gameByName(context: PersistenceController.preview.container.viewContext, name: "Blitz")!)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(UserSettings())
        }
    }
}
