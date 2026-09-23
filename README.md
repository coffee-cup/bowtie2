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

Build with Xcode 27 and Swift 6 language mode. The app supports iOS 16.6 and later; its Live Activity extension requires iOS 26. The SDK version and minimum supported iOS version are separate settings.

Use `$verify-bowtie` in Codex or `/verify-bowtie` in Cursor. Both load the same [verification skill](.cursor/skills/verify-bowtie/SKILL.md) and [feature map](.cursor/skills/verify-bowtie/features/README.md).

Run `python3 scripts/verify-bowtie.py run` for the score-entry and persistence smoke test on a disposable simulator. It requires Xcode and an installed iOS 26 or newer simulator runtime, and retains screenshots, logs and test results under `build/verification/`.

## Release tooling

Use Ruby 3.2 or newer instead of the macOS system Ruby. For Homebrew Ruby, put `$(brew --prefix ruby)/bin` ahead of `/usr/bin` in `PATH`. Fastlane and its Sentry plugin are locked in `Gemfile.lock`. Install them with:

```sh
gem install bundler -v 4.0.20
bundle config set --local path vendor/bundle
bundle install
bundle exec fastlane lanes
```

`bundle exec fastlane ios beta` increments the build number, archives and uploads to TestFlight using your configured Apple credentials. Select Xcode 27 before running it. Update dependencies deliberately with `bundle update`; release lanes do not update themselves.

## App Store screenshots

Run `python3 scripts/app-store-screenshots.py` to capture and render the four App Store images for iPhone and iPad. See [the screenshot guide](media/app-store/README.md) for setup, artwork settings, and export locations.
