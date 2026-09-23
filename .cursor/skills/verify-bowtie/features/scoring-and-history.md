# Scoring and history

A player card opens score entry. Scores accumulate across turns; history exposes individual entries, and the graph shows cumulative scores.

## Sub-features

- `score.calculator`: compute a score and return it to score entry.
- `score.commit`: save a turn and retain its total across app relaunch.
- `score.history`: inspect or delete individual turns.
- `score.graph`: show cumulative progression when enough turns exist.

## How to get to it (user POV)

- Games → a game → a player's card → Enter Score.
- Enter Score → Calculator → return to Enter Score → Go.
- Long-press a player card → View History → swipe a row to delete.
- Settings → Show graph; then open a game with at least two entries for a player.

## Driving it with XCUITest

Preconditions: one saved player and game created through the UI. Run `python3 scripts/verify-bowtie.py run` for calculator, commit and saved-history verification.

- Open entry: tap `app.buttons["scorePlayer.\(playerName)"]`; wait for `app.navigationBars["Enter Score for \(playerName)"]`.
- Calculate: tap `app.buttons["Calculator"]`; enter using `calculator.key.1`, `calculator.key.4`, `calculator.key.add`, `calculator.key.2`, `calculator.key.3`, `calculator.key.subtract`, `calculator.key.8`. Assert `Expression 14 + 23 − 8` and `29`. The existing test also exercises `calculator.key.delete` corrections.
- Commit: tap `calculator.key.enter`, assert `29` in score entry, then tap `Go`. Assert the scoreboard total is `29`. Terminate and relaunch, reopen the same game and assert the saved total.
- Inspect history: long-press the identified player card, tap `View History`, wait for `Score history for \(playerName)`, and assert exactly one cell containing `29`.
- Extend for deletion: swipe the identified history cell left and tap its `Delete` button. Assert `No scores entered so far`, return with `Done`, and verify the total is zero after relaunch.
- Extend for direct entry and graph: tap `score.key.1`, `score.key.0`, then `Go` twice in separate turns. Verify total `20`, two history rows and cumulative graph points at `10` and `20`. Capture the graph and inspect it visually; the drawn lines do not expose individual accessibility points.

## Gotchas

Returning a calculator result does not save a turn until Go is tapped. `Close` must leave the scoreboard unchanged. A negative turn uses the minus control in score entry; inspect its accessibility label before extending coverage. History deletion is the current way to undo a saved entry; do not invent an Undo button. Graph visibility also requires Show graph enabled. A seeded screenshot cannot establish that a score was committed or persisted.
