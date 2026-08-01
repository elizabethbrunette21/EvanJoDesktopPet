# EvanJoDesktopPet

**English** | [简体中文](README.zh-CN.md)

EvanJoDesktopPet is a small, native macOS desktop companion built in Swift with SwiftUI and AppKit. It renders a transparent, non-activating floating pet window and keeps all behavior and state local to the Mac.

EvanJoDesktopPet is a released macOS desktop pet application. Evan Jo is the first bundled character, while the window and behavior engine are structured so future characters can reuse the same application.

## Download

### Homebrew

```bash
brew install --cask elizabethbrunette21/tap/evan-jo-desktop-pet
```

### Direct download

[Download EvanJoDesktopPet 0.1.0 for macOS (.dmg)](https://github.com/elizabethbrunette21/EvanJoDesktopPet/releases/download/v0.1.0/EvanJoDesktopPet-0.1.0.dmg)

- Requires macOS 11.0 or later
- Supports Apple Silicon and Intel Macs
- Signed with Apple Developer ID
- Notarized by Apple

[View all releases](https://github.com/elizabethbrunette21/EvanJoDesktopPet/releases)


## Features

- Transparent, borderless floating window that does not take keyboard focus
- Dragging, visible-screen clamping, and saved position restoration
- Context menu with automatic and fixed poses, reset position, and quit
- Layered SwiftUI animations for Idle, Happy, Loading, Speechless, and Brainwave poses
- Automatic pose scheduling with cancellation-safe state transitions
- No backend, account, analytics, network service, or third-party dependency

## Requirements

- macOS 11 or later
- Xcode with the macOS SDK

## Build

Open `DesktopPet/EvanJoDesktopPet.xcodeproj` in Xcode and run the `EvanJoDesktopPet` target.

For a signing-disabled command-line build:

```bash
xcodebuild \
  -project DesktopPet/EvanJoDesktopPet.xcodeproj \
  -target EvanJoDesktopPet \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Repository layout

```text
DesktopPet/
  EvanJoDesktopPet/           App source and runtime assets
  EvanJoDesktopPet.xcodeproj/ Xcode project
  docs/                       Architecture and asset documentation
```

Raw character references, generation runs, Xcode user state, signing material, and local build output are intentionally excluded from version control.

All runtime assets required by the app are bundled in `DesktopPet/EvanJoDesktopPet/Resources/Assets.xcassets`. The local `DesktopPet/SourceAssets` directory contains source and rollback material, is excluded from version control, and is not a public runtime dependency.

## Project status

Version 0.1.0 has completed manual runtime testing, release packaging, Developer ID signing, and Apple notarization.

A signed and notarized Universal macOS installer is available from the GitHub Release page.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## Security and privacy

The app is local-only and does not make network requests. See [SECURITY.md](SECURITY.md) for responsible reporting.

## License

The source code and project documentation are open source under the
[MIT License](LICENSE).

The Evan Jo character name, identity, character design, illustrations,
animation layers, visual effects, and other visual assets are **not** licensed
under MIT and are not open source. They may be used only as necessary to
build, run, test, and evaluate this project for non-commercial purposes.
Standalone reuse, redistribution, derivative visual works, and commercial use
are prohibited. See [ASSET_LICENSE.md](ASSET_LICENSE.md) for the complete
terms.
