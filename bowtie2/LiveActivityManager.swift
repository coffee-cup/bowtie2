import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()

    @Published private(set) var currentActivity: Activity<GameActivityAttributes>?
    @Published private(set) var isRunning = false

    private init() {}

    var isSupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func start(game: Game) async throws {
        guard isSupported else { return }

        await endAll()

        let attributes = GameActivityAttributes(gameName: game.wrappedName)
        let state = contentState(from: game)
        let staleDate = Date().addingTimeInterval(30 * 60)

        let content = ActivityContent(
            state: state,
            staleDate: staleDate,
            relevanceScore: 100
        )

        let activity = try Activity.request(
            attributes: attributes,
            content: content,
            pushType: nil
        )

        currentActivity = activity
        isRunning = true
    }

    func update(game: Game) async {
        guard let activity = currentActivity else { return }

        let state = contentState(from: game)
        let staleDate = Date().addingTimeInterval(30 * 60)

        let content = ActivityContent(
            state: state,
            staleDate: staleDate,
            relevanceScore: 100
        )

        await activity.update(content)
    }

    func end() async {
        guard let activity = currentActivity else { return }

        await activity.end(nil, dismissalPolicy: .immediate)
        currentActivity = nil
        isRunning = false
    }

    func endAll() async {
        for activity in Activity<GameActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivity = nil
        isRunning = false
    }

    private func contentState(from game: Game) -> GameActivityAttributes.ContentState {
        let top4 = game.scoresArray.prefix(4).compactMap { score -> PlayerData? in
            guard let player = score.player else { return nil }
            return PlayerData(
                name: player.wrappedName,
                colorHex: player.wrappedColor,
                score: score.currentScore
            )
        }

        return GameActivityAttributes.ContentState(players: Array(top4))
    }
}
