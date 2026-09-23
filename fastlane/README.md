# Fastlane

Run commands from the repository root with Ruby 3.2 or newer and Bundler 4.0.20. See [release tooling](../README.md#release-tooling) for installation. Use the versions in `Gemfile.lock`; lanes do not update dependencies automatically.

```sh
bundle exec fastlane lanes
```

## Screenshots

```sh
bundle exec fastlane ios screenshots
```

Capture and render the iPhone and iPad App Store artwork.

## TestFlight

```sh
bundle exec fastlane ios beta
```

Select Xcode 27 and configure Apple credentials first. This lane increments the build number, archives Bowtie and uploads it to TestFlight.

## Debug symbols

```sh
bundle exec fastlane ios upload_symbols
```

Download available App Store debug symbols and upload those files to Sentry using the configured Apple and Sentry credentials.
