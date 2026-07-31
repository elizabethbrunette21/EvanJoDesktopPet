# Contributing

Thanks for helping improve EvanJoDesktopPet.

## Workflow

1. Open an issue before starting a large feature or architectural change.
2. Branch from `main` using a short-lived branch such as `feat/...`, `fix/...`, or `docs/...`.
3. Keep each pull request focused on one task.
4. Use concise commit messages in the form `type(scope): summary`, for example `fix(window): clamp restored position`.
5. Explain the user-visible change and verification performed in the pull request.

## Build verification

Run a signing-disabled Debug build before requesting review:

```bash
xcodebuild \
  -project DesktopPet/EvanJoDesktopPet.xcodeproj \
  -target EvanJoDesktopPet \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

The project currently has no automated test target. For UI or animation changes, describe the manual macOS checks performed.

## Scope and architecture

- Keep the shared desktop-pet engine character-agnostic.
- Keep character-specific poses, layout, assets, and animations inside the character pack.
- Prefer native SwiftUI and AppKit APIs; do not add dependencies without prior discussion.
- Preserve local-only behavior and do not add networking, analytics, accounts, or AI runtime dependencies as incidental changes.

## Assets and private files

Do not commit raw references, generation runs, signing files, Xcode user data, or files from ignored source-material directories. New artwork must include its ownership, license, source, and runtime role in the pull request.

By contributing code or documentation, you confirm that you have the right to
submit it under the repository's [MIT License](LICENSE).

The Evan Jo character and visual assets are governed separately by
[ASSET_LICENSE.md](ASSET_LICENSE.md) and are not open source. Do not add,
replace, or modify character artwork unless the repository owner has approved
the change and its ownership and licensing are documented explicitly.
