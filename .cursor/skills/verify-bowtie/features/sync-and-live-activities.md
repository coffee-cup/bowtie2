# iCloud and Live Activities

Saved games sync through iCloud. Live Activities show an active game's scores outside the app.

## Sub-features

- `sync.devices`: game, player and score changes appear on another device.
- `activity.lifecycle`: start, update and end the correct game's activity.
- `activity.settings`: respect global and per-game activity preferences.

## How to get to it (user POV)

Use Bowtie on two devices with the same test iCloud account. For activities, enable Settings → Live Activities, open a game, and check Game settings → Live Activity. Observe its Lock Screen or Dynamic Island presentation while scoring and switching games.

## Driving it with XCUITest

Preconditions: normal launch on suitable devices. The default disposable simulator is signed out, so its local persistence result does not establish iCloud sync.

- Local support checks: run `python3 scripts/verify-bowtie.py run --test bowtie2Tests/bowtie2Tests --test bowtie2Tests/PlayerOrderTests`. These assert content-state construction and local store behaviour only.
- Sync proof: with an explicitly provided test account/device setup, create a uniquely named game and player through device A's UI, enter a score, then observe the same values on device B. Change the score on B and observe A. Capture both devices and the elapsed wait; report non-convergence as failure or an environment blocker.
- Activity proof: set `app.switches["Live Activities"]` in Settings and `app.switches["Live Activity"]` in Game Settings. Enter a score through `scorePlayer.\(playerName)` and `Go`, then inspect the real system presentation. Switch games and disable the toggles, checking that the activity follows the intended game and ends when disabled.

## Gotchas

No current XCUITest automates two-device sync or the Lock Screen lifecycle. Report these paths as unverified until observed. Per-game Live Activity appears only when supported and globally enabled. The screenshot fixture disables both cloud sync and activities. Use an agreed test account and disposable records for cross-device checks; deleting a local simulator does not remove cloud records.
