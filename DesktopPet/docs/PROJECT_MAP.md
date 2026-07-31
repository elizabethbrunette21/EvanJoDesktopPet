# Project Map

## Current Status

The active implementation is one native macOS target named `EvanJoDesktopPet`, with Evan Jo as its only bundled character. Phase 5D0 and Phase 5D1 are complete. Phase 5D2 provides a build-verified Loading renderer, Phase 5D3 provides a build-verified Thinking renderer, and Phase 5D4 provides a build-verified split-layer Sleepy renderer pending user visual/runtime verification.

The product, project, target, scheme, module, source root, bundle identifier, repository, and asset names remain unchanged. No second character or character-selection feature exists.

## App Entry and Configuration

- **Project:** `EvanJoDesktopPet.xcodeproj`
- **Target/scheme/module/product:** `EvanJoDesktopPet`
- **Bundle identifier:** `com.elizabethbrunette.EvanJoDesktopPet`
- **Deployment target:** macOS 11.0
- **App entry:** `EvanJoDesktopPet/App/EvanJoDesktopPetApp.swift`
- **Composition root:** `EvanJoDesktopPet/App/AppDelegate.swift`
- **Selected definition:** `EvanJoCharacterDefinition.character`

## Swift File Classification

| File | Implemented role | Classification |
| --- | --- | --- |
| `App/EvanJoDesktopPetApp.swift` | Windowless SwiftUI app scene | Generic scene behavior; current product naming only |
| `App/AppDelegate.swift` | App lifecycle, Evan Jo definition selection, and controller retention | Composition root |
| `Features/DesktopPet/PetCharacterDefinition.swift` | String-backed pose IDs, declarative appearances, centralized automatic-pose configuration, pure weighted selection, ordered menu poses, and deterministic fallback | Shared character contract |
| `Characters/EvanJo/EvanJoCharacterDefinition.swift` | Evan Jo identity, pose mappings, behavior, and character-specific custom-renderer selection | Character-specific pack |
| `Characters/EvanJo/EvanJoIdleAnimatedView.swift` | Stationary body, head nod, sparkle sequence, and view-owned cancellation | Character-specific pack |
| `Characters/EvanJo/EvanJoLoadingAnimatedView.swift` | Loading text/body/spinner composition and view-scoped micro-animation | Character-specific pack |
| `Characters/EvanJo/EvanJoThinkingAnimatedView.swift` | Thinking glasses, bubble, dots, leaf path, Reduce Motion variant, and view-scoped cancellation | Character-specific pack |
| `Characters/EvanJo/EvanJoSleepyAnimatedView.swift` | Reference-mapped Sleepy mist/body/glasses/hand composition, temporary glasses reflection, persistent local sparkle, Reduce Motion variant, and view-scoped cancellation | Character-specific pack |
| `Features/DesktopPet/PetRootView.swift` | Optional custom-renderer hosting with static aspect-fit fallback | Shared renderer; no concrete character assets or pose branches |
| `Features/DesktopPet/PetWindowController.swift` | Panel construction, movement, persistence, definition-driven menu and behavior modes, one cancellation-safe automatic pose Task, rendering coordination, and lifecycle | Shared engine |
| `Features/DesktopPet/PetPanel.swift` | Non-key, non-main AppKit panel | Shared engine; unchanged in Phase 5D0 |
| `Features/DesktopPet/PetInteractionView.swift` | Hit testing, first mouse, 4-point click/drag classification, drag callbacks, and contextual-menu presentation | Shared engine; unchanged in Phase 5D0 |

## Implemented Character Boundary

- `AppDelegate` injects one bundled `PetCharacterDefinition` into `PetWindowController`.
- `PetWindowController` asks the definition for the default pose, menu appearances, click reaction, idle-delay range, automatic candidates, durations, and resolved appearance.
- `PetRootView` consumes only `PetPoseAppearance` values and invokes an optional bundled custom-renderer closure.
- The generic engine has no direct references to the five Evan Jo pose asset names and no closed `CaseIterable` pose enum.
- Missing requested IDs resolve once to a guaranteed concrete fallback appearance. Unsupported menu and automatic IDs are filtered out.
- The contextual menu is definition-driven in the order declared by the selected character.
- The `desktopPet.panelPosition` key and its versioned value format remain unchanged.

## Evan Jo Definition

- Stable ID `evan_jo`; display/accessibility name `Evan Jo`.
- Idle is the default and fallback.
- Menu order is Idle, Happy, Loading, internal Thinking displayed as `Speechless`, and internal Sleepy displayed as `Brainwave`.
- All poses use a 125 × 132 logical canvas and zero image offset.
- Idle uses its character-specific 160 × 148 panel. Loading uses a character-specific renderer in a 176 × 132 panel; its centered body leaves the added width for one text layer to travel behind it. Thinking uses a character-specific renderer in a 176 × 154 panel with a stable body baseline and a reference-mapped bubble/dots layout. Sleepy uses a character-specific renderer in a 176 × 154 panel with a 130.7 pt Idle-matched visible height, one feet-anchored reference transform, an independently calibrated hand frame, temporary white reflection below the hand, and a persistent left-temple yellow sparkle.
- Happy uses scale 1.18, bottom alignment, zero horizontal inset, and a 156 × 140 panel.
- Sleepy retains scale 1.16, center alignment, and 7-point horizontal insets for its static fallback.
- Click uses Happy for 1.8 seconds and temporarily interrupts Auto without disabling it.
- Auto starts with Idle for 6–10 seconds, then selects Thinking/Happy/Sleepy at weights 40/35/25 for 5/1.8/8 seconds. Every expression returns through Idle for a 4–7 second recovery. Consecutive repeats are excluded, and Sleepy has a two-selection cooldown.
- Loading is excluded from automatic selection. Existing manual Loading remains available, and the controller exposes a highest-priority loading override for a real busy-state owner.

## Shared Behavior Preserved by the Refactor

- transparent, borderless, floating, nonactivating panel setup;
- keyboard-focus preservation;
- click-versus-drag classification and dragging;
- bottom-center panel resizing anchor;
- screen selection, visible-frame clamping, and display-change recovery;
- position persistence/restoration and Reset Position;
- Auto/fixed behavior-mode mechanics and menu checkmarks;
- one automatic Task, generation-based stale-work rejection, cancellation, weak ownership, and cleanup;
- contextual Quit and one-window lifecycle.

These behaviors remain unchanged; Phase 5D0 manual runtime verification passed.

## Assets

The flat runtime catalog at `EvanJoDesktopPet/Resources/Assets.xcassets` retains all five static pose assets plus Idle, Happy, Loading, Thinking, and Sleepy animation layers. Sleepy uses Idle-palette runtime derivatives for `EvanJoSleepyBodyBack` and `EvanJoSleepyHandFront`; its original full Body and Impact Streak remain preserved but are not rendered by the custom renderer. `EvanJoIdle`, `EvanJoLoading`, `EvanJoThinking`, and `EvanJoSleepy` remain static fallback assets. Thinking's complete reference is preserved under `SourceAssets` and is no longer bundled; no runtime external path is used.

`../_archive/tartan-pet-run` is not present in the current worktree. It was never part of the runtime architecture and was moved to Trash after the project-owned source and runtime assets were verified.

## Verification and Next Gate

- `EvanJoSleepyAnimatedView.swift` is explicitly referenced in the target source build phase.
- Phase 5D4 static asset checks passed and one signing-disabled Debug macOS build succeeded.
- Automatic scheduling static checks passed and one signing-disabled Debug macOS build succeeded using an external temporary DerivedData directory.
- The app was not launched; user manual runtime verification of automatic scheduling is the current gate.

## Still Planned or Not Implemented

- Second character and character selection/persistence
- Frame-by-frame animation
- Breathing, floating, and click-bounce animation
- Autonomous walking or other movement
- Sound
- Pause/resume controls
- Launch at login
- Packaging
