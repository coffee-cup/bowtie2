import ActivityKit
import Foundation

struct PlayerData: Codable, Hashable {
    let name: String
    let colorHex: String
    let score: Int
}

struct GameActivityAttributes: ActivityAttributes {
    let gameName: String

    struct ContentState: Codable, Hashable {
        let players: [PlayerData]
    }
}
