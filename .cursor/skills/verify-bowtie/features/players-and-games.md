# Players and games

Players have names and colours and can be reused across games. A game starts with a name and selected players.

## Sub-features

- `players.create-edit`: create a reusable player; edit their name and colour.
- `games.create`: create a named game with selected players.
- `games.manage`: rename, duplicate or delete a game; edit its membership.
- `players.delete`: remove a player after reviewing the game-count confirmation.

## How to get to it (user POV)

- Players tab → Create Player on an empty list, or Add Player in the toolbar.
- Games tab → Create First Game on an empty list, or Create Game in the toolbar.
- Create Game → Create player when there are none, or the plus beside Who's playing.
- Tap an existing player to edit. Long-press a player for Delete Player.
- Long-press a game for Duplicate Game or Delete Game. Open a game → Game settings → Edit to change its players.

## Driving it with XCUITest

Preconditions: normal launch on a fresh simulator; dismiss `app.buttons["Get Started"]` if present. Run the default verification command for the empty-list creation path.

- Create a player: tap `app.tabBars.buttons["Players"]`, then `app.buttons["Create Player"]` or `app.buttons["Add Player"]`. Fill `app.textFields["Player name"]`, tap `app.buttons["Create"]`, and assert the new name appears.
- Create a game: tap `app.tabBars.buttons["Games"]`, then `Create First Game` or `Create Game`. Fill `app.textFields["Canasta"]`, select `app.switches["Include player \(playerName)"]`, and tap `Create`. Open the new game and assert `app.buttons["scorePlayer.\(playerName)"]` exists with a zero score.
- Cancellation: tap `Close` on an uncommitted form and assert no new row appears. Verify Create remains disabled with an empty name or no selected players.
- Edit: tap the player's name, edit `Player name`, tap `Save`, then inspect the updated player in an existing game and after relaunch. Inspect the accessibility tree for the unlabelled colour swatch before adding a selector.
- Manage games: use a long press on the unique game title, then `Duplicate Game` or `Delete Game`. Confirm `Delete` only for the disposable record. Verify duplication retains the participants with fresh scores; deletion removes only that game after relaunch.

## Gotchas

The default test covers creation through empty lists. It does not exercise inline player creation, colour selection, duplication, deletion or edit paths. The inline plus lacks a dedicated accessibility identifier; inspect the actual hierarchy rather than guessing. Names need unique suffixes because score-card identifiers include names. Player deletion and removing someone from a game are different flows and need separate assertions.
