# Appearance and premium

Settings controls graphs, themes and app icons. Premium unlocks additional cosmetic choices.

## Sub-features

- `appearance.layout`: inspect light/dark game, entry and creation screens.
- `appearance.preferences`: retain graph, theme and icon choices.
- `premium.entitlement`: purchase or restore premium through StoreKit.

## How to get to it (user POV)

Settings tab → Show graph, Theme, App icon, or ✨ Premium ✨. Selecting a locked theme or icon also opens premium. Premium has Close and Restore controls and, when a product is available, Get Premium.

## Driving it with XCUITest

Preconditions: use a separate fresh simulator run for the existing screenshot class.

```sh
python3 scripts/verify-bowtie.py run --test bowtie2UITests/AppStoreScreenshotTests
```

- Light layout: the existing test opens `Go Fish 🐠`, checks `1805`, `1475` and `1120`, then taps `scorePlayer.Aleesha` and checks `score.key.9` in entry. Inspect the exported games, leaderboard and entry screenshots.
- Dark creation: the existing test opens `Create Game`, fills `Canasta`, toggles named players and captures the enabled Create form. This test does not submit it.
- For purchase/restore coverage, use a configured StoreKit test or sandbox account and assert entitlement and unlocked choices after relaunch.

Normal-launch preferences coverage:

```sh
python3 scripts/verify-bowtie.py run --test bowtie2UITests/bowtie2UITests/testAppearancePreferencesPersistAfterRelaunch
```

The test disables Show graph and Live Activities, selects `theme.Cherryblossoms`, then relaunches and checks persisted switch values and the theme's Selected accessibility value. It also opens and dismisses premium without purchasing, and restores graph/activity preferences for other normal-launch tests.

Alternate icons have a separate test, `bowtie2UITests/bowtie2UITests/testAlternateAppIconPersistsAfterRelaunch`. It selects `appIcon.cherryblossoms`, checks selection, captures SpringBoard, then relaunches to verify the selected icon. Inspect the Home Screen attachment before claiming the icon artwork is correct. The test explicitly skips iOS 26.5.0 and 27.0.0 simulators: the system icon-change request did not complete, including in a pre-upgrade Swift 5 baseline run on iOS 27. Icon switching remains unverified on a physical device. To investigate a simulator fix, remove the narrow runtime skip and run this method alone.

## Gotchas

On iOS 27, a labelled settings switch contains a nested interactive switch. Tap `app.switches["Show graph"].switches.firstMatch` and assert the labelled row's value; tapping the row centre does not change it.

The screenshot fixture resets settings, disables activities and reseeds in-memory data on launch. It is only layout evidence. The repository currently has no StoreKit test configuration. A Not Available purchase state is not a successful purchase test. App icon changes also need a SpringBoard observation. The artwork renderer creates marketing images; use raw XCTest screenshots as behaviour evidence.
