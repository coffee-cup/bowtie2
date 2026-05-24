import ActivityKit
import Foundation
import OSLog

@MainActor
final class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()

    nonisolated static let staleInterval: TimeInterval = 30 * 60

    @Published private(set) var currentActivity: Activity<GameActivityAttributes>?
    @Published private(set) var isRunning = false

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.jakerunzer.bowtie2", category: "LiveActivity")
    private var desiredGame: Game?
    private var isGameContextVisible = false
    private var activityStateTask: Task<Void, Never>?
    private var observedActivityID: String?

    private init() {}

    var isAvailable: Bool {
        if #available(iOS 26, *) {
            return true
        }
        return false
    }

    var isSupported: Bool {
        guard isAvailable else { return false }
        return ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func activateGameContext(game: Game, settingsEnabled: Bool) async {
        desiredGame = game
        isGameContextVisible = true
        await reconcileGameContext(settingsEnabled: settingsEnabled)
    }

    func restoreGameContext(settingsEnabled: Bool) async {
        isGameContextVisible = desiredGame != nil
        await reconcileGameContext(settingsEnabled: settingsEnabled)
    }

    func hideGameContext() async {
        isGameContextVisible = false
        await endAll()
    }

    func clearGameContext() async {
        desiredGame = nil
        isGameContextVisible = false
        await endAll()
    }

    func reconcileGameContext(settingsEnabled: Bool) async {
        guard isGameContextVisible,
              settingsEnabled,
              let game = desiredGame,
              game.liveActivityEnabled else {
            await endAll()
            return
        }

        do {
            try await ensureStarted(game: game)
        } catch {
            logger.error("Failed to reconcile Live Activity: \(error.localizedDescription, privacy: .public)")
        }
    }

    func start(game: Game) async throws {
        desiredGame = game
        isGameContextVisible = true
        try await ensureStarted(game: game)
    }

    func ensureStarted(game: Game) async throws {
        guard isSupported else {
            logger.info("Live Activities are disabled by the system")
            await endAll()
            return
        }

        let gameID = game.liveActivityID
        let activeActivities = Activity<GameActivityAttributes>.activities
        let matchingActivities = activeActivities.filter { $0.attributes.gameID == gameID }

        if let matchingActivity = matchingActivities.first,
           matchingActivity.attributes.gameName == game.wrappedName {
            setCurrentActivity(matchingActivity)
            await update(activity: matchingActivity, game: game)
            await end(activities: activeActivities.filter { $0.id != matchingActivity.id })
            return
        }

        let activity = try requestActivity(game: game)
        setCurrentActivity(activity)
        await end(activities: Activity<GameActivityAttributes>.activities.filter { $0.id != activity.id })
    }

    func update(game: Game) async {
        guard isAvailable else {
            clearCurrentActivity()
            return
        }

        let gameID = game.liveActivityID
        let activity = currentActivity?.attributes.gameID == gameID
            ? currentActivity
            : Activity<GameActivityAttributes>.activities.first { $0.attributes.gameID == gameID }

        guard let activity else {
            guard isGameContextVisible, desiredGame?.liveActivityID == gameID else { return }
            do {
                try await ensureStarted(game: game)
            } catch {
                logger.error("Failed to restart missing Live Activity during update: \(error.localizedDescription, privacy: .public)")
            }
            return
        }

        setCurrentActivity(activity)
        await update(activity: activity, game: game)
    }

    func end() async {
        await endAll()
    }

    func endWithDelayedDismissal(game: Game, delay: TimeInterval = LiveActivityManager.staleInterval) async {
        guard isAvailable else { return }

        let gameID = game.liveActivityID
        let activities = Activity<GameActivityAttributes>.activities.filter { $0.attributes.gameID == gameID }
        let content = activityContent(from: game, staleDate: nil, relevanceScore: 0)

        for activity in activities {
            logger.info("Ending Live Activity after delay: \(activity.id, privacy: .public)")
            await activity.end(content, dismissalPolicy: .after(Date().addingTimeInterval(delay)))
        }

        clearCurrentActivityIfNeeded(endedIDs: Set(activities.map(\.id)))
    }

    func endAll() async {
        guard isAvailable else {
            clearCurrentActivity()
            return
        }

        let activities = Activity<GameActivityAttributes>.activities
        await end(activities: activities)
        if activities.isEmpty {
            clearCurrentActivity()
        }
    }

    static func contentState(from game: Game) -> GameActivityAttributes.ContentState {
        let allPlayers = game.scoresArray.compactMap { score -> PlayerData? in
            guard let player = score.player else { return nil }
            return PlayerData(
                name: player.wrappedName,
                colorHex: player.wrappedColor,
                score: score.currentScore
            )
        }

        return GameActivityAttributes.ContentState(
            players: allPlayers,
            totalPlayers: game.scoresArray.count,
            roundCount: game.maxNumberOfEntries
        )
    }

    private func requestActivity(game: Game) throws -> Activity<GameActivityAttributes> {
        let attributes = GameActivityAttributes(gameID: game.liveActivityID, gameName: game.wrappedName)
        let content = activityContent(from: game)

        logger.info("Requesting Live Activity for game: \(game.wrappedName, privacy: .public)")

        return try Activity.request(
            attributes: attributes,
            content: content,
            pushType: nil
        )
    }

    private func update(activity: Activity<GameActivityAttributes>, game: Game) async {
        let content = activityContent(from: game)
        logger.info("Updating Live Activity: \(activity.id, privacy: .public)")
        await activity.update(content)
    }

    private func activityContent(
        from game: Game,
        staleDate: Date? = Date().addingTimeInterval(LiveActivityManager.staleInterval),
        relevanceScore: Double = 100
    ) -> ActivityContent<GameActivityAttributes.ContentState> {
        ActivityContent(
            state: Self.contentState(from: game),
            staleDate: staleDate,
            relevanceScore: relevanceScore
        )
    }

    private func end(activities: [Activity<GameActivityAttributes>]) async {
        guard !activities.isEmpty else {
            if currentActivity == nil {
                isRunning = false
            }
            return
        }

        for activity in activities {
            logger.info("Ending Live Activity: \(activity.id, privacy: .public)")
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        clearCurrentActivityIfNeeded(endedIDs: Set(activities.map(\.id)))
    }

    private func setCurrentActivity(_ activity: Activity<GameActivityAttributes>) {
        currentActivity = activity
        isRunning = true
        observeStateUpdates(for: activity)
    }

    private func clearCurrentActivityIfNeeded(endedIDs: Set<String>) {
        guard let currentActivity else { return }
        if endedIDs.contains(currentActivity.id) {
            clearCurrentActivity()
        }
    }

    private func clearCurrentActivity() {
        currentActivity = nil
        isRunning = false
        activityStateTask?.cancel()
        activityStateTask = nil
        observedActivityID = nil
    }

    private func observeStateUpdates(for activity: Activity<GameActivityAttributes>) {
        guard observedActivityID != activity.id else { return }

        activityStateTask?.cancel()
        observedActivityID = activity.id
        activityStateTask = Task { [weak self] in
            for await state in activity.activityStateUpdates {
                await MainActor.run {
                    guard let self else { return }
                    self.logger.info("Live Activity state changed: \(String(describing: state), privacy: .public)")

                    switch state {
                    case .active, .stale:
                        if self.currentActivity?.id == activity.id {
                            self.isRunning = true
                        }
                    case .ended, .dismissed:
                        if self.currentActivity?.id == activity.id {
                            self.currentActivity = nil
                            self.isRunning = false
                            self.activityStateTask = nil
                            self.observedActivityID = nil
                        }
                    @unknown default:
                        break
                    }
                }
            }
        }
    }
}
