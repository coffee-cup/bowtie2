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
                    LeadingExpandedView(players: context.state.players)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    TrailingExpandedView(players: context.state.players)
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
                }
            } compactTrailing: {
                if let leader = context.state.players.first {
                    Text("\(leader.score)")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
            } minimal: {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
            }
        }
    }
}

struct LockScreenView: View {
    let context: ActivityViewContext<GameActivityAttributes>

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(context.attributes.gameName)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
            }

            HStack(spacing: 12) {
                ForEach(Array(context.state.players.enumerated()), id: \.element) { index, player in
                    PlayerScoreItem(player: player, rank: index + 1)
                }

                if context.state.players.count < 4 {
                    ForEach(0 ..< (4 - context.state.players.count), id: \.self) { _ in
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .activityBackgroundTint(.black.opacity(0.8))
    }
}

struct PlayerScoreItem: View {
    let player: PlayerData
    let rank: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("\(player.score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: player.colorHex))

            Text(player.name)
                .font(.caption2)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LeadingExpandedView: View {
    let players: [PlayerData]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(players.prefix(2).enumerated()), id: \.element) { _, player in
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
    }
}

struct TrailingExpandedView: View {
    let players: [PlayerData]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(players.dropFirst(2).prefix(2).enumerated()), id: \.element) { _, player in
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
    }
}

#Preview("Notification", as: .content, using: GameActivityAttributes(gameName: "Catan")) {
    GameLiveActivity()
} contentStates: {
    GameActivityAttributes.ContentState(players: [
        PlayerData(name: "Alice", colorHex: "FF5733", score: 42),
        PlayerData(name: "Bob", colorHex: "33FF57", score: 38),
        PlayerData(name: "Charlie", colorHex: "3357FF", score: 35),
        PlayerData(name: "Diana", colorHex: "FF33F5", score: 30),
    ])
}
