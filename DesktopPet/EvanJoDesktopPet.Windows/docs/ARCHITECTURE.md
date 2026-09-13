# Windows architecture

## Purpose

The Windows app is an independent WPF implementation that uses the existing macOS app as a behavioral and product reference. It does not share build files, source files, or runtime assets with the Swift project.

## Phase 2 boundaries

`App.xaml` is the WPF application entry point and opens `DesktopPetWindow`.

`Core/Characters` defines the open-ended character contract and string-backed `PetPoseId` identity. A future character may create a new `PetPoseId` without changing a shared enum.

`Characters/EvanJo` owns Evan Jo's identity, five static pose labels, and pose-to-resource mapping. `EvanJoPoseView` only hosts the selected pose renderer; it does not own window movement, placement, menus, animation, or behavior.

`Features/DesktopPet` owns the desktop-pet window lifecycle: initial placement, dragging, and the context menu. `PetRenderer` renders a requested pose from any `IPetCharacterDefinition` and falls back through that definition when a requested asset is unavailable.

`Platform/Windowing` isolates WPF window policy. `TransparentPetWindow` supplies the transparent, borderless, topmost, taskbar-hidden, non-activating shell expected by a desktop pet. Future Windows interop should remain inside this platform boundary.

## Dependency direction

```text
App.xaml
  -> Features/DesktopPet/DesktopPetWindow
       -> Characters/EvanJo/EvanJoCharacterDefinition
       -> Characters/EvanJo/Views/EvanJoPoseView
            -> Features/DesktopPet/PetRenderer
                 -> Core/Characters/IPetCharacterDefinition
       -> Platform/Windowing/TransparentPetWindow
```

The feature layer may depend on the Windows platform layer. The platform layer must not depend on characters, assets, or behavior.

## Current window behavior

- Window surface: 160 × 148 device-independent pixels, matching the macOS Idle panel.
- Character canvas: 125 × 132 device-independent pixels, matching the macOS static fallback canvas. `PetRenderer` uses `Stretch="Uniform"` to preserve each PNG's aspect ratio and transparent margins.
- Initial placement: primary display working area, 24 px from the right and bottom edges.
- Pointer handling: only the centered character canvas receives pointer events; the surrounding transparent window margin has no background and does not receive hits.
- Context menu: a definition-driven Pose submenu (Idle, Happy, Loading, Thinking, Sleepy), Reset Position, and Quit EvanJoDesktopPet.

## Explicitly deferred

- character switching
- animation and pose transitions
- click reactions and gestures
- automatic or scheduled behavior
- screen clamping after dragging and saved position
- startup integration, packaging, and distribution

These items require a later approved phase.

## macOS reference boundary

The `EvanJoDesktopPet` Swift source directory and `EvanJoDesktopPet.xcodeproj` remain the reference implementation. Windows work must stay under `EvanJoDesktopPet.Windows` and must not rename, move, or edit the macOS project.
