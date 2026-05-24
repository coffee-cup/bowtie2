# Bowtie

iOS score-keeping app for tracking games with multiple players.

## Core Features

- Create games and add players with custom colors
- Track scores round-by-round with undo support
- Visualize score progression via graphs
- Sync game data across devices via iCloud
- Premium tier unlocks additional themes and app icons

## Tech Stack

SwiftUI + CoreData with CloudKit sync. Minimum iOS 16.6.

## Build

Run after making big changes to verify syntax/compilation:

```bash
xcodebuild -scheme bowtie2 -destination 'generic/platform=iOS' build CODE_SIGNING_ALLOWED=NO
```
