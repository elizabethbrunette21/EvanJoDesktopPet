# Internal Character Packs

## 1. Purpose

An internal character pack keeps one character’s assets, presentation, behavior choices, and future animations separate from the shared desktop-pet engine. Evan Jo is the first current pack. Future characters reuse the same application and engine rather than copying the Xcode project.

A pack is bundled Swift and resource organization. It is not a plugin, downloaded extension, executable module, third-party framework, or external package format.

## 2. Shared Engine Responsibilities

The shared engine owns:

- app lifecycle and composition;
- transparent, borderless, floating, nonactivating panel behavior;
- keyboard-focus preservation;
- click-versus-drag classification and dragging;
- screen selection, boundary clamping, and display-change recovery;
- position persistence, restoration, and Reset Position;
- contextual-menu, Quit, and future generic Hide/Pause infrastructure;
- automatic/fixed behavior-mode mechanics;
- timer scheduling, cancellation, weak callbacks, and lifecycle cleanup;
- the rendering host for the selected character;
- future character selection and persistence infrastructure.

The engine must not directly depend on one character name, fixed asset list, pose dimensions, click reaction, automatic pose choices, or animation implementation.

## 3. Character-Pack Responsibilities

Each pack owns:

- stable character ID and display name;
- available pose definitions and asset mapping;
- supported, unsupported, and manual-only poses;
- logical canvas size, image scale, anchor/alignment, and panel/content bounds;
- click reaction and automatic idle choices;
- temporary-pose durations;
- character-specific animated views when separately approved;
- source-asset location and app-ready resource ownership;
- fallback behavior for unavailable poses or animations.

## 4. Minimum Character Definition

The smallest useful definition contains values for:

- `id` and `displayName`;
- default pose ID;
- ordered manual-menu pose IDs;
- pose appearance mapping;
- optional click reaction;
- automatic idle interval and eligible temporary poses;
- fallback pose ID.

Use small value types. Do not introduce a protocol hierarchy, dependency-injection container, registry framework, or manifest parser unless a confirmed need exceeds this contract.

## 5. Pose Mapping and Optional-Pose Rules

Shared semantic pose IDs may include concepts such as Idle, Happy, Loading, Thinking, and Sleepy, but they are not a mandatory checklist for every character.

A character may:

- map a semantic pose to its own asset or renderer;
- omit an unsupported pose;
- expose a pose manually but exclude it from automatic behavior;
- replace a semantic reaction with another supported pose;
- add a character-specific pose ID when a shared semantic state is insufficient.

Menus and automatic behavior must be derived from the selected character definition rather than a global `CaseIterable` pose list.

## 6. Appearance Sizing and Anchoring

Each pose appearance may define its asset name or renderable content, logical canvas size, scale, alignment/anchor, and panel size or content bounds. The engine applies those values while preserving bottom-center positioning, visible-screen clamping, and position persistence.

One character’s exceptional layout must not become a global branch in the generic rendering host.

## 7. Behavior Configuration

A pack defines its click reaction, automatic idle candidates, temporary-pose durations, and manual-only poses. The engine owns timer creation and cancellation but does not choose a character’s reactions.

Automatic choices must include only poses supported by the selected pack. Missing or empty choices safely return to the default pose without polling or background work.

## 8. Character-Specific Animation Ownership

Character-specific animation views and layer composition belong to the character pack. The shared host may display a supplied character view, but it must not contain Evan Jo-specific head, body, star, flower, or frame logic.

Animation remains separately approved work. A static pose must remain a valid fallback when an animation is absent or disabled.

## 9. Asset Organization

Source assets should be organized conceptually by character, with separate pose, animation-layer, and reference areas. Runtime asset catalogs may remain flat when necessary, provided stable prefixes make ownership unambiguous.

- Source/file ID example: `evan_jo`
- Source filename example: `evan_jo_idle_head.png`
- Xcode asset prefix example: `EvanJo`
- Xcode asset example: `EvanJoIdleHead`

Every character retains untouched sources, app-ready derivatives, provenance, and rollback information under `docs/ASSET_PIPELINE.md`.

## 10. Fallback Policy

If a requested pose is unavailable, use the pack’s declared fallback pose. If a character-specific animation is unavailable, render the corresponding static pose when available, otherwise the fallback pose. Unsupported poses are omitted from menus and automatic choices.

Fallback must remain local and deterministic. It must not download assets, consult a service, or silently substitute another character’s resources.

The Phase 5D0 value model requires a concrete fallback appearance when a definition is constructed. Missing requested pose IDs therefore resolve directly to that value, without recursive fallback lookup. Unsupported menu and automatic-behavior IDs are omitted.

## 11. Future Character-Addition Checklist

1. Choose a stable ID and display name.
2. Add untouched source assets in that character’s source area.
3. Add validated app-ready pose assets with a stable prefix.
4. Create the character definition.
5. Declare supported, unsupported, and manual-only poses.
6. Define size, scale, bounds, and anchor for each supported appearance.
7. Define click reaction and automatic behavior choices/durations.
8. Add optional character-specific animations only when separately approved.
9. Run one focused build under the task’s verification budget.
10. Manually verify presentation, menus, interactions, focus, dragging, clamping, and persistence.

Phase 0–4 lifecycle, panel, interaction, movement, clamping, persistence, and contextual-menu infrastructure is reused and is not repeated for each character.

## 12. Explicit Non-Goals

- Dynamic plugin loading
- Downloadable executable characters
- Separate Xcode projects per character
- Third-party character frameworks
- External package or manifest formats
- A dependency-injection system or speculative registry hierarchy
- Character-selection UI in the boundary-refactor phase
- Animation implementation in the boundary-refactor phase
- Another product/project rename without separate approval

## 13. Phase 5D0 Implemented Boundary

Phase 5D0 implements the minimum contract with two concrete Swift files:

- `Features/DesktopPet/PetCharacterDefinition.swift` defines the shared string-backed pose ID, appearance, temporary-pose behavior, character identity, ordered menu, and deterministic fallback values.
- `Characters/EvanJo/EvanJoCharacterDefinition.swift` defines the bundled Evan Jo pack.

`AppDelegate` selects Evan Jo and injects the definition into `PetWindowController`. The controller remains responsible for generic menu mechanics, timing, cancellation, panel resizing, persistence, dragging coordination, and lifecycle. `PetRootView` renders only the supplied appearance. Neither generic file maps concrete Evan Jo asset names.

The current Evan Jo pack declares:

- stable ID `evan_jo`, display/accessibility name `Evan Jo`, and Idle default/fallback;
- menu order Idle, Happy, Loading, Thinking, Sleepy;
- a 125 × 132 logical canvas and zero image offset for every pose;
- Idle `EvanJoIdle`, scale 1.0, centered, 125 × 132 panel;
- Happy `EvanJoHappy`, scale 1.18, bottom-aligned, 156 × 140 panel;
- Loading `EvanJoLoading`, scale 1.0, centered, 125 × 132 panel;
- Thinking `EvanJoThinking`, scale 1.0, centered, 125 × 132 panel;
- Sleepy `EvanJoSleepy`, scale 1.16, centered, 7-point horizontal insets, 125 × 132 panel;
- Happy click feedback for 1.8 seconds;
- a 60–120 second automatic idle delay;
- equally eligible Thinking and Sleepy temporary poses lasting 5 and 8 seconds;
- Loading as manual-only.

Phase 5D0 manual runtime verification passed and the boundary remains closed. Phase 5D1 uses the appearance’s optional custom-renderer closure to select `EvanJoIdleAnimatedView` only for Evan Jo Idle; static rendering remains the fallback for every pose. No second character, selection UI, persistence expansion, product rename, plugin system, or generic animation framework was added.
