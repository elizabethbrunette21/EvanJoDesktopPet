# Working Memory

- **Current task:** Windows character proportions and missing pose animations,
  approved by the user after confirming the Windows implementation in
  `/Users/liz/Documents/pet` on 2026-10-21.
- **Scope:** `EvanJoDesktopPet.Windows`; Swift/macOS code and original assets are
  reference-only. Existing uncommitted Windows presentation and Happy asset
  corrections are preserved.
- **Layout:** One 240 x 184 DIP surface; visible body height about 130.7 DIP and
  feet y=176. Idle's native layout is unchanged apart from placement. Happy uses
  native reference head/body dimensions; flowers are 1.5x the reference atlas
  size and fit their complete outward trajectories.
- **Animation:** Idle/Happy start only when loaded and visible. Loading, Thinking
  and Sleepy now have local layered WPF timelines. Switching states stops old
  playback; selecting the same pose again restarts it. The three new renderers
  honor the Windows client-area animation preference. Static fallback remains.
- **Assets:** Sixteen existing macOS runtime layers are copied byte-for-byte into
  Windows resources. No image generation, reference overwrite or OpenAI API use.
- **Behavior boundary:** Automatic mode still restores Idle only; automatic pose
  scheduling, roaming and persistence are outside this task.
- **Verification:** Asset/layout regression check passes: Idle/Happy heights
  differ by less than 0.5 DIP, feet differ by less than 0.1 DIP, all seven flower
  paths fit and all new PNGs decode. One .NET 8.0.426 Debug build passed
  with 0 warnings and 0 errors. Windows runtime visual QA is pending.
- **Git:** The user authorized committing and pushing the Windows visual fixes
  to GitHub on 2026-10-21. Keep unrelated local changes out of the commit.
- **Next step:** Validate the compiled Windows package on the user's Windows
  machine at common DPI settings.
