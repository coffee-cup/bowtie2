# Bowtie verification map

Read the matching feature before choosing tests. Run recipes on the disposable simulator created by `python3 scripts/verify-bowtie.py run`. Tests create their own data through the UI unless explicitly marked as screenshot fixtures. Use unique player and game names, English UI selectors, and readiness assertions.

| Feature | Existing executable coverage | Additional paths to cover when relevant |
| --- | --- | --- |
| [Players and games](players-and-games.md) | Default test creates both from empty lists | Populated lists, inline player creation, edit, colour, duplicate, delete |
| [Scoring and history](scoring-and-history.md) | Default test calculates, commits, cancels, saves a negative turn, checks graph visibility and deletes history across relaunches | Individual graph-point accessibility |
| [Player order and game settings](player-order.md) | Manual order UI test covers drag, cancel, save, scoring, relaunch and large text | Winner mode, membership editing, awake setting |
| [Appearance and premium](appearance-and-premium.md) | Screenshot tests cover seeded light/dark layouts; preferences test covers settings, themes and premium presentation | Alternate icon system service; StoreKit purchase and restore |
| [iCloud and Live Activities](sync-and-live-activities.md) | Model tests cover activity content and local persistence | Two-device sync and real Lock Screen activity lifecycle |

The default command verifies only the paths its test executes. Map entries with no automated coverage are recipes for extending XCUITest or performing a device check, not claims that they already pass. For every requested entry point, report passed, failed, or unverified with the reason and evidence location.

Screenshots are `.keepAlways` XCTest attachments. Include the action trace and assertions in the result bundle. A persistence claim requires normal launch and a relaunch assertion. For destructive flows, use data created in this run.
