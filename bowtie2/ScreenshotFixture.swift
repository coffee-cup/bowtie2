#if DEBUG && targetEnvironment(simulator)
import CoreData
import SwiftUI

/// Recreated from the four original App Store images. Only used in disposable simulators.
enum ScreenshotFixture {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("--app-store-screenshots")
    }

    static var colorScheme: ColorScheme? {
        guard isEnabled else { return nil }
        return ProcessInfo.processInfo.arguments.contains("--screenshot-dark") ? .dark : .light
    }

    static func seed(_ context: NSManagedObjectContext) {
        let players = [
            ("Jake", "EB3298"), ("Aleesha", "E9B34F"), ("Gab", "335FF0"),
            ("Jim", "88D0EE"), ("Pam", "D75B36"), ("Macaroni", "F6DE94")
        ]
        var people: [String: Player] = [:]
        for (name, color) in players {
            people[name] = Player.createPlayer(context: context, name: name, colour: color)
        }

        // Eight rounds with the original totals and an approximation of the original graph.
        let histories = [
            "Jake": [0, 270, 170, 170, 565, 225, 155, 250],
            "Aleesha": [40, 600, 10, 435, 540, -330, 165, 15],
            "Gab": [440, -160, 250, 410, 370, -110, -300, 220]
        ]
        let baseDate = ISO8601DateFormatter().date(from: "2026-09-12T12:00:00Z")!
        func game(_ name: String, day: Int, scores: [(String, [Int])]) {
            let game = Game.createGame(context: context, name: name)
            game.created = baseDate.addingTimeInterval(Double(day) * 86400)
            game.liveActivityEnabled = false
            for (name, history) in scores {
                PlayerScore.createPlayerScore(context: context, game: game, player: people[name]!, history: history)
            }
        }
        game("Go Fish 🐠", day: 0, scores: ["Jake", "Aleesha", "Gab"].map { ($0, histories[$0]!) })
        game("Canasta", day: 1, scores: [("Jim", [200, 300]), ("Pam", [250, 250])])
        game("Nickels", day: 2, scores: [("Aleesha", [100, 200]), ("Macaroni", [80, 120])])
        game("Racko 🎲", day: 3, scores: [("Gab", [100, 200]), ("Jim", [100, 100]), ("Pam", [50, 100])])
        do {
            try context.save()
        } catch {
            fatalError("Could not create App Store screenshot data: \(error)")
        }
    }
}
#endif
