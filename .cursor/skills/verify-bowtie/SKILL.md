---
name: verify-bowtie
description: Verify Bowtie iOS behaviour on an isolated simulator using XCUITest, with screenshots and saved-data checks. Use after changing a user flow or when asked to prove a Bowtie feature works.
---

# Verify Bowtie

Read [the feature map](features/README.md), then the files matching the requested behaviour. Choose the entry points and observable results before running tests. Report exactly what the selected tests prove and which requested paths remain unverified.

Run commands from the repository root. The shared `bowtie2` scheme builds the SwiftUI app, widget extension, unit tests and UI tests. The app targets iOS 16.6, but the widget currently targets iOS 26.0. Use an installed iOS 26 or newer runtime for the complete scheme.

## Launch

```sh
python3 scripts/verify-bowtie.py doctor
python3 scripts/verify-bowtie.py run
```

The runner builds Debug app and test bundles, creates and boots a fresh simulator, checks it, then lets XCUITest install and launch Bowtie. The default test creates a player and game through the UI, calculates `14 + 23 − 8`, commits `29`, relaunches and checks the saved score in history. Readiness means the test finds the expected screen or control with `waitForExistence`, not just a successful launch command.

The default device is iPhone 17 Pro with the newest installed iOS runtime. Pin or change the device using identifiers from `xcrun simctl list runtimes` and `xcrun simctl list devicetypes`:

```sh
python3 scripts/verify-bowtie.py run --runtime com.apple.CoreSimulator.SimRuntime.iOS-26-5
python3 scripts/verify-bowtie.py run --device-type com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-12GB
```

Each invocation owns its simulator and temporary build directory. It never reuses a booted simulator. Fresh simulators have no signed-in iCloud account. Normal launch uses the real persistent store and may attempt CloudKit or StoreKit requests; this is not an offline mode. Do not sign into a personal account for routine verification.

## Doctor

`python3 scripts/verify-bowtie.py doctor` reads the selected Xcode version and installed runtimes without creating or booting a device. During a run, take `simulatorID` from its `run.json` and use:

```sh
python3 scripts/verify-bowtie.py doctor --device-id "$BOWTIE_SIMULATOR_ID"
```

Require the device to be available and booted and its name to match `simulatorName` in that run. The runner also saves `doctor.json` before driving it. Build provenance is in `run.json`, `working-tree.patch` and `build.log`; app readiness is asserted by XCTest. A doctor result alone does not prove the correct app screen is open.

For CoreSimulator connection errors in a sandbox, rerun through the tool's normal permission mechanism. For compilation or test failures, inspect the retained log before retrying. Report unrelated blockers instead of changing deployment targets or signing settings to get a pass.

## Drive

Use the existing XCUITest target, not coordinate scripts or SwiftUI previews. Select a test by its real target/class/method identifier:

```sh
python3 scripts/verify-bowtie.py run --test bowtie2UITests/bowtie2UITests/testManualPlayerOrderDragSaveCancelAndReopen
python3 scripts/verify-bowtie.py run --test bowtie2UITests/AppStoreScreenshotTests
python3 scripts/verify-bowtie.py run --test bowtie2Tests
```

Repeat `--test` to combine compatible tests. Run `AppStoreScreenshotTests` separately: its normal-launch test expects an empty persistent store, while the normal UI tests create saved games. Unit tests supplement UI evidence; they do not prove the user flow.

For a changed flow without coverage, extend the matching test in `bowtie2UITests/bowtie2UITests.swift`, or add a test and register its file in the Xcode test target. Use the feature map's selectors, assert the resulting state, then pass its identifier to `--test`. Missing identifiers should be resolved from the actual accessibility hierarchy, attached with `XCTAttachment(string: app.debugDescription)`. Do not guess screen coordinates. The existing reorder helper deliberately drags within identified table cells because UIKit exposes a drag handle there.

## Evidence

The runner prints a unique directory under `build/verification/run-*/`. It retains:

- `run.json`, environment and doctor reports, revision and tracked working-tree diff.
- `build.log`, `boot.log`, `test.log`, plus `summary.json` after a successful test invocation.
- `tests.xcresult` with XCTest actions and assertions, and `attachments/` with exported screenshots and a manifest.

Capture the action and resulting state with XCTest activities, assertions and `.keepAlways` attachments. Inspect relevant exported screenshots before claiming visual correctness. An exit code of zero with no executed tests is not a pass; the runner checks the result summary. Check skipped tests against the requested scope.

For a mutation, reopen the screen and, when persistence matters, terminate and relaunch before asserting the value. Check history or another user-visible view as a second observation. `--app-store-screenshots` seeds an in-memory store on each launch, disables CloudKit and Live Activities, skips onboarding and resets display settings. Use that mode for layout evidence only. It cannot prove persistence, sync, activity lifecycle, or creation merely by displaying seeded data.

Report feature IDs and entry points, expected and actual results, the evidence path, and any skipped coverage. Inspect failed runs as evidence too. Build success does not establish UI, iCloud sync, premium purchases, or Lock Screen behaviour.

## Cleanup

The runner shuts down and deletes only its recorded simulator and removes its temporary build directory, including after failures and handled interruptions. Evidence stays in `build/verification/`. Confirm `simulatorDeleted: true` in `run.json` and that the result bundle and relevant attachments still exist.

If the runner is forcibly killed or cleanup fails, first match the recorded ID and name using `xcrun simctl list devices -j`, then shut down and delete that exact simulator. Never use `shutdown all`, erase shared simulators, or kill processes by name. Preserve the evidence directory.

## Maintenance

When a verified flow changes, update its feature entry and executable test together. Keep gaps explicit until the path has actually run. The feature map follows the [create-verification-skill approach](https://github.com/cursor/plugins/blob/main/pstack/skills/create-verification-skill/SKILL.md). If that plugin is available, `/maintain-verification-skill` can help keep the map current.
