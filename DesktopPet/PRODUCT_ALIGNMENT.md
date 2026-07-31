# Product Alignment

## Current Implementation Identity

- **Current product/app name:** `EvanJoDesktopPet`
- **Repository root:** `DesktopPet`
- **Current Xcode project, target, scheme, and module:** `EvanJoDesktopPet`
- **Current bundle identifier:** `com.elizabethbrunette.EvanJoDesktopPet`
- **First current character:** `Evan Jo`
- **Evan Jo Swift/asset prefix:** `EvanJo`
- **Evan Jo source/file ID:** `evan_jo`

The current app and project name may remain character-specific until a separate naming decision is explicitly approved. This temporary product naming does not make Evan Jo the permanent identity of the architecture.

## Product Direction

This is a native macOS desktop-pet application designed to support multiple characters bundled inside one app. Evan Jo is the first character and may be the only character in the first working MVP, but future characters must reuse the same shared desktop-pet engine rather than duplicate the project.

The shared engine owns window lifecycle, transparent nonactivating panel behavior, dragging, click classification, screen clamping, position persistence, contextual controls, behavior scheduling, timer lifecycle, and the rendering host. Character-specific poses, assets, dimensions, behavior choices, and animations belong to internal character packs.

Character switching and character-selection persistence may be added later. They are not authorized by the current documentation task.

## First Functional MVP

The first working MVP may run with Evan Jo only and should include:

- A transparent, borderless, floating, nonactivating window
- A bundled character rendered from local assets
- Dragging without stealing keyboard focus
- Visible-screen clamping
- Saved position restoration
- A contextual menu
- Reset Position and Quit
- Lightweight click and automatic behavior
- Local-only operation

Hide and pause/resume controls remain possible later MVP work and are not authorized by this document alone.

## Multi-Character Requirements

- New characters reuse the Phase 0–4 shared infrastructure and current interaction/window behavior.
- A character may map, omit, or replace shared semantic poses; every character is not required to reproduce Evan Jo’s exact pose list.
- A character pack is an internal Swift/resource organization pattern bundled with the application.
- Adding a character must not require copying the Xcode project, window controller, interaction view, or persistence implementation.
- Shared-engine code must not permanently depend on Evan Jo asset names, dimensions, reactions, or animations.

## Non-Goals for the First MVP

- Dynamic plugins or downloaded character executables
- External character package formats or manifest parsers
- Accounts, authentication, cloud services, backend, or database
- AI, networking, or remote asset delivery
- Third-party frameworks for character loading
- Complex autonomous behavior
- App Store distribution or automatic startup

## Asset Independence

The application must remain usable with bundled local assets and must not depend on Hatch Pet generation or any external producer succeeding. Each character owns its source and app-ready assets, while the shared engine consumes only the character definition and selected renderable content.
