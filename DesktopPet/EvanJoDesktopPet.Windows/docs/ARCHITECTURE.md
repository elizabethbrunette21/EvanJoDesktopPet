# Windows architecture

The independent .NET 8 WPF application uses the Swift/macOS app as its visual
reference. It has no third-party runtime dependencies.

`Core/Characters` defines character identity, pose IDs, static assets and static
presentation parameters. `Core/Behavior` manages selected poses, cancellable
click reactions, and the definition-driven automatic expression cycle.

`Features/DesktopPet` owns window placement, dragging, menus and the generic
static fallback renderer. The window sizes to its content. Character dimensions
and animation assets stay in `Characters/EvanJo`, rather than in window code.

`EvanJoPoseView` owns a constant 240 x 184 DIP surface and selects the active
renderer. Idle retains its original 160 x 148 layout with a 28 DIP top inset.
Happy uses its native head/body dimensions. Its seven flowers each display the
same full reference atlas through a character-specific mask and anchor, then
expand to 1.8 times the Swift atlas scale. The three jump lines use the original
layer above the flowers, placed as thin strokes just below the feet. Loading,
Thinking and Sleepy use
`EvanJoExpressionAnimationView`: three local scene builders and native WPF
storyboards. Their complete compositions are scaled using the visible body
bounds, aligned to x=120 and feet y=176, and clipped only at the outer surface.
Loading text additionally has its own clipping region.

A selected renderer starts after it is loaded and visible. Switching poses
removes its controllable storyboard; selecting the same pose again creates a
fresh playback. Missing layer sets fall back to the existing static renderer.
All resource PNGs are bundled by the existing project resource glob.

`Platform/Windowing` owns transparency and native window policy. Its `WM_MOVING`
hook keeps the pet visible within the nearest monitor's work area while dragging,
with a character-supplied allowance for transparent canvas at the right edge. It
remains independent of character names, assets and animations.

Automatic mode starts with Idle, then selects weighted character expressions
using the Swift reference durations, repeat exclusion and Sleepy cooldown.
Click reactions interrupt the cycle, finish on Idle, then resume after the
recovery delay. Dragging suspends the cycle; fixed poses stop it. A loading
override remains available for a future busy-state owner.

The Windows implementation does not modify the Swift source, Xcode project or
original artwork. New runtime layers are byte-identical copies of the approved
macOS Asset Catalog resources.
