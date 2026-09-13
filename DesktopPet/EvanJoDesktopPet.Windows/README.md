# EvanJoDesktopPet for Windows

This directory contains the separate Windows implementation of EvanJoDesktopPet. It is a sibling of the existing Swift/macOS project and does not replace or modify it.

## Phase 2 status

Phase 2 adds a static character-pack and pose foundation to the Windows MVP:

- C# with .NET 8 and WPF
- a transparent, borderless, topmost WPF window
- a definition-driven Evan Jo character pack with five static poses
- a generic renderer that resolves pose assets through the selected definition
- macOS-reference Idle sizing inside a 160 × 148 device-independent-pixel surface
- bottom-right primary-working-area placement with a 24 px margin
- drag movement and a right-click pose menu with Reset Position and Quit

Animations, character switching, click reactions, gestures, autonomous
behavior, persistence, and packaging are intentionally not implemented.

## Requirements

- Windows 10 or later
- .NET 8 SDK

## Build

From this directory on Windows:

```powershell
dotnet restore .\EvanJoDesktopPet.Windows.sln
dotnet build .\EvanJoDesktopPet.Windows.sln --configuration Debug --no-restore
```

Run the desktop pet with:

```powershell
dotnet run --project .\src\EvanJoDesktopPet.Windows\EvanJoDesktopPet.Windows.csproj
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the Phase 2 boundaries and deferred work.
