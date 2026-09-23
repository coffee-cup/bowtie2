# Bowtie

[![CI](https://github.com/coffee-cup/bowtie2/actions/workflows/ci.yml/badge.svg)](https://github.com/coffee-cup/bowtie2/actions/workflows/ci.yml)

Score keeping iOS app made with SwiftUI

![](https://bowtie.cards/og.png)

- [Website](https://bowtie.cards)
- [App Store](https://apps.apple.com/ca/app/bowtie-score-keeping-app/id1544635020#?platform=iphone)

## Features

- Games synced between devices with iCloud
- Custom colour for each player
- Graph scores throughout a game
- History for all your previous games

## Verification

Use `$verify-bowtie` in Codex or `/verify-bowtie` in Cursor. Both load the same [verification skill](.cursor/skills/verify-bowtie/SKILL.md) and [feature map](.cursor/skills/verify-bowtie/features/README.md).

Run `python3 scripts/verify-bowtie.py run` for the score-entry and persistence smoke test on a disposable simulator. It requires Xcode and an installed iOS 26 or newer simulator runtime, and retains screenshots, logs and test results under `build/verification/`.

## App Store screenshots

Run `python3 scripts/app-store-screenshots.py` to capture and render the four App Store images for iPhone and iPad. See [the screenshot guide](media/app-store/README.md) for setup, artwork settings, and export locations.
