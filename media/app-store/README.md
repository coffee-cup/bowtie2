# App Store screenshots

Generate the same four marketing images from the current app, using fixed sample games and the original gradient colors.

## Generate

Requires macOS, Xcode with command-line tools selected, Python 3, and the iOS simulator runtime in `config.json`. No Python packages, image editor, physical device, signing credentials, or App Store login are required.

From the repository root:

```sh
python3 scripts/app-store-screenshots.py
```

If the existing Fastlane bundle is installed, `bundle exec fastlane ios screenshots` runs the same command.

The generator builds the app and UI tests, creates a disposable simulator for each selected device, captures the four screens, and renders opaque sRGB PNGs. It shuts down and deletes its simulators when finished or when a test fails. It does not modify existing simulators or upload anything.

Open `media/app-store/index.html` to review the results. Upload these folders to their respective Media Manager slots:

- `media/app-store/upload/en-US/iphone-6.9/`: four 1320 × 2868 images.
- `media/app-store/upload/en-US/ipad-13/`: four 2064 × 2752 images.

`media/app-store/bowtie-app-store-screenshots.zip` contains the upload-ready images in device folders.

Contact sheets live beside the device folders. Raw app screenshots live under `media/app-store/raw/en-US/`. These media assets can be committed with the templates and original references. Build caches and diagnostics stay under the gitignored `build/app-store/` directory. Each `run-*` directory there contains logs, test results, a configuration copy, and a manifest recording Xcode, the runtime, and the source revision.

## Iterate

```sh
# Generate one device.
python3 scripts/app-store-screenshots.py --device iphone-6.9

# Change artwork without rebuilding or recapturing the app.
python3 scripts/app-store-screenshots.py --render-only

# Reuse the previously built tests when no Swift code has changed.
python3 scripts/app-store-screenshots.py --skip-build
```

`--device` can be repeated. `--output /absolute/path` changes the media output directory. `--build-dir /absolute/path` changes the separate build and diagnostics directory. A rendering-only run needs raw captures for each selected device.

## Edit the source

- `config.json`: headlines, left-to-right gradient colors, simulator runtime, and device sizes.
- `references/`: the downloaded original images, retained as design references.
- `../../scripts/render-app-store.swift`: scalable device frames, title placement, shadows, and layout. Uses macOS AppKit and Core Graphics.
- `../../bowtie2/ScreenshotFixture.swift`: fixed player names, colors, dates, and round histories.
- `../../bowtie2UITests/AppStoreScreenshotTests.swift`: the real app interactions and screenshot assertions.

The screenshot fixture is compiled only in simulator Debug builds and requires the `--app-store-screenshots` launch argument. It uses an ephemeral Core Data store with CloudKit disabled. Normal launches continue using the existing persistent store. Screenshot runs disable onboarding and Live Activities and use the default app theme. The first three screens use light mode; game creation uses dark mode.

The eight Go Fish rounds reproduce the original totals of 1805, 1475, and 1120. Individual round values approximate the graph because the original data was unavailable. Game dates are fixed in September 2026. The current UI determines player ordering and sheet layout.

### Original gradients

These sRGB values were sampled from the leftmost and rightmost pixels of the unobstructed top row of each original PNG. The originals use horizontal gradients with no vertical color change.

| Image | Left | Right |
| --- | --- | --- |
| Leaderboard | `#FF7781` | `#FF3D8C` |
| Score entry | `#F2747E` | `#FABBA2` |
| Previous games | `#E8A6CA` | `#CE649C` |
| Game creation | `#00AEFF` | `#008AFF` |

The device frames are drawn from vector geometry. The iPhone frame adds the hardware cutout omitted by simulator screenshots. The iPad uses its own full native app capture and frame, with no stretching of phone screenshots.

The `iphone` frame assumes a Dynamic Island device. Older notched or home-button models need a corresponding frame implementation before adding them to the configuration.

## Device sizes and uploads

Checked September 15, 2026 against Apple's [screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications) and [upload/scaling guidance](https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots).

The default sets cover the 6.9-inch iPhone and 13-inch iPad slots. Apple can scale these to smaller displays when the interface is equivalent. Replace or clear old screenshots in other explicitly populated slots when updating the listing, so older artwork does not remain in use.

To add a device, add its simulator device type and native portrait pixel dimensions to `config.json`. Use `xcrun simctl list devicetypes` and `xcrun simctl list runtimes` to find installed identifiers. Select the `iphone` or `ipad` frame. The renderer rejects screenshots whose dimensions differ from the configuration. Check Apple's accepted sizes before uploading a new set.

The current fixture, headlines, and UI tests are English. Additional localizations require translated headlines and corresponding UI test selectors.

## Troubleshooting

- Missing runtime: install it in Xcode Settings > Components, or select an installed compatible runtime in `config.json`.
- Failed capture: inspect the run's `capture.log` and `.xcresult` bundle. Failed runs retain diagnostics and do not substitute an older screenshot.
- Wrong dimensions: check the simulator model against the configured dimensions. Do not stretch a different device's capture.
- Changed navigation or labels: update the screenshot UI test and run it again.
- Stale app after `--skip-build`: rerun without that option.

For CI, use a macOS runner with the configured runtime installed, run the same command, and retain the `upload/`, `raw/`, `index.html`, and run manifests as artifacts. Screenshot generation is intentionally separate from every-push unit tests.
