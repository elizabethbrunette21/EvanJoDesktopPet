# Windows architecture

The independent .NET 8 WPF application uses the Swift/macOS app as its visual
reference. It has no third-party runtime dependencies.

`Core/Characters` defines character identity, pose IDs, static assets and static
presentation parameters. `Core/Behavior` manages selected poses and cancellable
click reactions; it does not schedule autonomous expressions.

`Features/DesktopPet` owns window placement, dragging, menus and the generic
static fallback renderer. The window sizes to its content. Character dimensions
and animation assets stay in `Characters/EvanJo`, rather than in window code.

`EvanJoPoseView` owns a constant 240 x 184 DIP surface and selects the active
renderer. Idle retains its original 160 x 148 layout with a 28 DIP top inset.
Happy uses its native head/body dimensions and enlarges each existing flower crop
around its centre. Loading, Thinking and Sleepy use
`EvanJoExpressionAnimationView`: three local scene builders and native WPF
storyboards. Their complete compositions are scaled using the visible body
bounds, aligned to x=120 and feet y=176, and clipped only at the outer surface.
Loading text additionally has its own clipping region.

A selected renderer starts after it is loaded and visible. Switching poses
removes its controllable storyboard; selecting the same pose again creates a
fresh playback. Missing layer sets fall back to the existing static renderer.
All resource PNGs are bundled by the existing project resource glob.

`Platform/Windowing` owns transparency and native window policy. It must remain
independent of character names, assets and animations.

The Windows implementation does not modify the Swift source, Xcode project or
original artwork. New runtime layers are byte-identical copies of the approved
macOS Asset Catalog resources.
