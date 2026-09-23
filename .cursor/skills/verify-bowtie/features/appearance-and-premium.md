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
- Extend preferences on normal launch: tap `app.tabBars.buttons["Settings"]`, change `app.switches["Show graph"]`, then reopen a qualifying game. Relaunch to check persistence. Navigate through `Theme` or `App icon`, select a named available option and inspect the result.
- Extend premium presentation: open `app.buttons["✨ Premium ✨"]`, verify the premium sheet and dismiss with `Close`. Test actual purchase and restore only with a configured StoreKit test or sandbox account, asserting entitlement and unlocked choices after relaunch.

## Gotchas

The screenshot fixture resets settings, disables activities and reseeds in-memory data on launch. It is only layout evidence. The repository currently has no StoreKit test configuration. A Not Available purchase state is not a successful purchase test. App icon changes also need a SpringBoard observation. The artwork renderer creates marketing images; use raw XCTest screenshots as behaviour evidence.
