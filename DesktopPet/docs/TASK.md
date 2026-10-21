# Current Task

## Approved scope

Correct Windows character scale across all five poses, enlarge Happy flowers,
and complete the missing pose animations. The user confirmed the Windows
implementation on 2026-10-21.

## Implementation

- Use a stable surface with one visible-body height and foot baseline.
- Preserve existing Idle/Happy artwork and local presentation work.
- Increase Happy flowers without clipping their trajectories.
- Add Loading, Thinking and Sleepy layers from existing approved runtime assets.
- Stop hidden animations, defer playback until loaded/visible and replay a
  manually reselected pose.
- Keep character-specific dimensions and timelines inside the character pack.

## Verification and limits

The asset-aware layout check passes. One .NET 8.0.426 Debug build passed
with 0 warnings and 0 errors. Windows runtime visual verification is pending. Check each pose, repeated Happy selection, fast switching out of
Loading, and 100%/150%/200% display scale on Windows.

No Swift/macOS changes, generated artwork, new runtime dependencies, automatic
pose scheduler are included. The user subsequently authorized committing and
pushing the completed Windows fixes to GitHub on 2026-10-21.
