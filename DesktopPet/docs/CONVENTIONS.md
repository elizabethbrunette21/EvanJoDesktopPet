# Future Code Conventions

These conventions apply only after implementation is explicitly approved. They do not authorize source-code creation during Phase 0.

## Swift and SwiftUI Naming

- Follow the Swift API Design Guidelines and standard Swift capitalization.
- Name types and protocols with `UpperCamelCase`; name properties, functions, and enum cases with `lowerCamelCase`.
- Use role-based names that describe domain responsibility. Avoid generic names such as `Manager`, `Helper`, or `Utils` when a precise name is available.
- Name SwiftUI views for the user-facing element or screen they render.
- Keep genuinely shared engine types character-neutral, including names such as `PetPanel`, `PetWindowController`, and `PetInteractionView`.
- Use a character prefix such as `EvanJo` for Swift definitions and asset names owned by that character.
- Do not add a character prefix to generic engine types, and do not give a generic name to a character-specific implementation.

## File Responsibility

- Give each file one primary responsibility.
- Keep SwiftUI views small and focused; extract a view only when it has a clear responsibility or reusable behavior.
- Keep services focused on one boundary such as position persistence or asset loading.
- Do not create speculative protocols, layers, or folders for future scale.

## AppKit Bridge Boundaries

- Keep AppKit imports and window-specific behavior behind a narrow, explicit boundary.
- Use AppKit only for macOS window behavior or platform integration that SwiftUI cannot provide cleanly.
- Do not let `NSWindow` details leak into unrelated views, persistence, asset loading, or product state.

## Dependencies and State Ownership

- Dependency direction should flow from the app composition root to views and focused services, never from services back into views.
- Each piece of observable state must have one clear owner.
- Prefer explicit construction and injected dependencies over hidden lookups.
- Avoid global mutable state and duplicate sources of truth.
- Keep persistence and asset I/O outside view rendering.

## Safety and Clarity

- Do not force-unwrap unless the invariant is narrow, documented, and justified at the point of use.
- Handle expected failure paths deterministically and keep safe local defaults.
- Comments should explain why a decision or constraint exists, not restate what the code says.
- Prefer plain native APIs and no third-party dependencies during the MVP.

## Product-Facing Behavior

- Keep behavior deterministic and local. The app must not depend on a backend, AI service, or network response.
- Add accessibility labels and appropriate help text to interactive controls.
- Keep user-facing strings ready for future localization by avoiding sentence fragments assembled in code, but do not add localization infrastructure before it is needed.
- Respect visible-screen bounds and avoid taking keyboard focus unnecessarily.

## Resource Naming

- Use a stable lower-snake-case character ID for source and file prefixes, such as `evan_jo` and `evan_jo_idle`.
- Use the corresponding UpperCamelCase character prefix for Swift types and Xcode asset names, such as `EvanJo` and `EvanJoIdle`.
- Include role or state in a resource name only when it distinguishes real variants; do not encode temporary workflow status into canonical names.
- Keep source references, temporary MVP assets, canonical runtime assets, and generated intermediates clearly distinct.
- Never use absolute paths to development or Hatch Pet directories in application code.
- Document spritesheet frame dimensions, layout, direction mapping, and animation mapping alongside any imported canonical spritesheet.
