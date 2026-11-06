# Current Task

## Scope

Publish the Windows x64 preview with the macOS app icon, a desktop shortcut,
and English and Chinese download instructions. Push the accumulated Windows
interaction and animation changes that the user explicitly requested.

## Changes

- Encode the existing macOS AppIcon artwork as a multi-size Windows ICO and
  embed it in the executable and shortcut.
- Package the self-contained app with a per-user installer.
- Publish the ZIP from a `windows-v*` tag with GitHub Actions and link it from
  both root READMEs and the Windows README.

## Verification and limits

The character behavior probe and routed WPF mouse-up probe passed earlier for
Idle → Happy and Loading → Brainwave. A Windows x64 self-contained publish passed
with the temporary .NET 8.0.426 SDK. The ZIP contains the executable and installer
scripts, and the executable icon can be extracted. The installed executable hash
matches the package; the desktop shortcut targets it and uses its icon. GitHub
Release publication and live download verification remain pending.
