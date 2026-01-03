import ActivityKit
import SwiftUI
import WidgetKit

struct GameLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GameActivityAttributes.self) { context in
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedPlayersView(players: context.state.players, totalPlayers: context.state.totalPlayers)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack {
                        Text("\(context.state.roundCount)")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("rounds")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.gameName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                if let leader = context.state.players.first {
                    Circle()
                        .fill(Color(hex: leader.colorHex))
                        .frame(width: 12, height: 12)
                } else {
                    Image(systemName: "gamecontroller.fill")
                        .font(.caption2)
                }
            } compactTrailing: {
                Text("\(context.state.roundCount)")
                    .font(.caption2)
                    .fontWeight(.bold)
            } minimal: {
                Image(systemName: "gamecontroller.fill")
                    .font(.caption2)
            }
        }
    }
}

struct LockScreenView: View {
    let context: ActivityViewContext<GameActivityAttributes>

    private var displayPlayers: (visible: [PlayerData], hasMore: Bool, lastPlayer: PlayerData?) {
        let all = context.state.players
        if all.count <= 4 {
            return (all, false, nil)
        }
        let visible = Array(all.prefix(3))
        let last = all.last
        return (visible, true, last)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(context.attributes.gameName)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("\(context.state.roundCount)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                ForEach(Array(displayPlayers.visible.enumerated()), id: \.element) { _, player in
                    PlayerScoreItem(player: player)
                }

                if displayPlayers.hasMore {
                    Text("···")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    if let last = displayPlayers.lastPlayer {
                        PlayerScoreItem(player: last)
                    }
                }

                Spacer()
            }
        }
        .padding()
        .activityBackgroundTint(.black.opacity(0.8))
    }
}

struct PlayerScoreItem: View {
    let player: PlayerData

    var body: some View {
        VStack(spacing: 2) {
            Text("\(player.score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: player.colorHex))

            Text(player.name)
                .font(.caption2)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(minWidth: 44)
    }
}

struct ExpandedPlayersView: View {
    let players: [PlayerData]
    let totalPlayers: Int

    private var displayPlayers: (visible: [PlayerData], hasMore: Bool, lastPlayer: PlayerData?) {
        if players.count <= 4 {
            return (players, false, nil)
        }
        let visible = Array(players.prefix(3))
        let last = players.last
        return (visible, true, last)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(Array(displayPlayers.visible.enumerated()), id: \.element) { _, player in
                PlayerRow(player: player)
            }

            if displayPlayers.hasMore {
                HStack(spacing: 6) {
                    Text("···")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                if let last = displayPlayers.lastPlayer {
                    PlayerRow(player: last)
                }
            }
        }
    }
}

struct PlayerRow: View {
    let player: PlayerData

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(hex: player.colorHex))
                .frame(width: 8, height: 8)
            Text(player.name)
                .font(.caption)
                .lineLimit(1)
            Spacer()
            Text("\(player.score)")
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

#Preview("Notification", as: .content, using: GameActivityAttributes(gameName: "Catan")) {
    GameLiveActivity()
} contentStates: {
    GameActivityAttributes.ContentState(
        players: [
            PlayerData(name: "Alice", colorHex: "FF5733", score: 42),
            PlayerData(name: "Bob", colorHex: "33FF57", score: 38),
            PlayerData(name: "Charlie", colorHex: "3357FF", score: 35),
            PlayerData(name: "Diana", colorHex: "FF33F5", score: 30),
            PlayerData(name: "Eve", colorHex: "33FFF5", score: 25),
        ],
        totalPlayers: 5,
        roundCount: 12
    )
}
