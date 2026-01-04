import ActivityKit
import SwiftUI
import WidgetKit

struct GameLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GameActivityAttributes.self) { context in
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    HStack {
                        Text(context.attributes.gameName)
                            .font(.caption)
                        Spacer()
                        Text("\(context.state.roundCount) rounds")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    let players = context.state.players
                    ViewThatFits(in: .horizontal) {
                        PlayerScoreRow(players: players, maxVisible: players.count)
                        PlayerScoreRow(players: players, maxVisible: 5)
                        PlayerScoreRow(players: players, maxVisible: 4)
                        PlayerScoreRow(players: players, maxVisible: 3)
                    }
                    .padding(.horizontal, 8)
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

            let players = context.state.players
            ViewThatFits(in: .horizontal) {
                PlayerScoreRow(players: players, maxVisible: players.count)
                PlayerScoreRow(players: players, maxVisible: 5)
                PlayerScoreRow(players: players, maxVisible: 4)
                PlayerScoreRow(players: players, maxVisible: 3)
                PlayerScoreRow(players: players, maxVisible: 2)
            }
        }
        .padding()
        .activityBackgroundTint(.black.opacity(0.8))
    }
}

struct PlayerScoreRow: View {
    let players: [PlayerData]
    let maxVisible: Int

    private var displayConfig: (visible: [PlayerData], lastPlayer: PlayerData?) {
        if players.count <= maxVisible {
            return (players, nil)
        }
        let visible = Array(players.prefix(maxVisible - 1))
        return (visible, players.last)
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(displayConfig.visible, id: \.self) { player in
                PlayerScoreItem(player: player)
                    .frame(maxWidth: .infinity)
            }

            if let last = displayConfig.lastPlayer {
                VStack(spacing: 4) {
                    Text("···")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .frame(minHeight: 28)
                        .padding(.vertical, 4)
                    Text(" ")
                        .font(.caption2)
                }
                PlayerScoreItem(player: last)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct PlayerScoreItem: View {
    let player: PlayerData

    var body: some View {
        VStack(spacing: 4) {
            Text("\(player.score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, minHeight: 28)
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
                .background(Color(hex: player.colorHex))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(player.name)
                .font(.caption2)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(minWidth: 44)
    }
}

#Preview("Notification", as: .content, using: GameActivityAttributes(gameName: "Catan")) {
    GameLiveActivity()
} contentStates: {
    GameActivityAttributes.ContentState(
        players: [
            PlayerData(name: "Alice", colorHex: "FF5733", score: 4200000),
            PlayerData(name: "Bob", colorHex: "33FF57", score: -1123),
            PlayerData(name: "Charlie", colorHex: "3357FF", score: 35),
            PlayerData(name: "Diana", colorHex: "FF33F5", score: 30),
            PlayerData(name: "Eve", colorHex: "33FFF5", score: 25),
        ],
        totalPlayers: 5,
        roundCount: 12
    )
}
