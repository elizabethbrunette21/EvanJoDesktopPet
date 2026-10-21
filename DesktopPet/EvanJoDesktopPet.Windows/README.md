# EvanJoDesktopPet for Windows

Native .NET 8 / WPF desktop pet with bundled, local-only character assets.

## Current behavior

- Transparent, borderless, topmost, non-activating window; drag and right-click controls.
- Five layered poses: Idle nod/petting sparkles; Happy jump/flower burst;
  Loading spinner/scrolling text; Thinking glasses/bubble/dots/leaf;
  Sleepy mist/glasses reflection/sparkle.
- A fixed 240 x 184 DIP character surface reserves room for effects. Character
  bodies are approximately 130.7 DIP tall, with the feet at y=176 across poses.
- Happy's four large flowers are approximately 24–26 DIP wide. The smaller
  decorative dots retain their relative sizes; all seven trajectories fit.
- Clicking plays Happy temporarily. Selecting the same pose again replays its
  animation. Hidden or removed renderers stop their timelines.
- Loading, Thinking and Sleepy honor the Windows client-area animation setting.
- Static fallback images remain available when a layer set cannot be loaded.

The Automatic menu mode currently restores Idle; it does not schedule a random
pose cycle. Character switching, roaming, saved position and packaging remain
separate work.

## Build and run on Windows

Requires Windows 10 or later and the .NET 8 SDK. From this directory:

```powershell
dotnet build .\EvanJoDesktopPet.Windows.sln --configuration Debug
dotnet run --project .\src\EvanJoDesktopPet.Windows\EvanJoDesktopPet.Windows.csproj --no-build
```

## Focused verification

The 2026-10-21 visual fix passed a .NET 8.0.426 Debug cross-build with 0 warnings
and 0 errors, plus the asset/layout check below. Windows runtime visual QA is
still pending.

The asset/layout regression check requires Python 3 and Pillow:

```powershell
python .\tests\check_visual_layout.py
```

It measures the actual transparent image bounds, compares Idle/Happy heights and
feet, checks all flower paths against the surface, and validates the new layers.

On Windows, select each pose from the context menu, select Happy twice, and
switch out of Loading while its text is moving. Check that the body stays at the
same scale and baseline, flowers are fully visible, and old effects stop. Repeat
at 100%, 150% and 200% display scale. Runtime visual approval remains required.

The Swift/macOS implementation remains a read-only visual reference. This
Windows project bundles its own copies of approved runtime PNGs and does not
require the macOS source tree to build or run.
