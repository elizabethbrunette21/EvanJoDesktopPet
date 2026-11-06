# Working Memory

- **Current task:** Publish the Windows preview with the macOS app icon, bilingual download instructions, and a desktop shortcut.
- **Scope:** Windows x64 package and release workflow, English and Chinese READMEs, and accumulated Windows interaction changes explicitly requested for push.
- **Implementation:** The macOS AppIcon artwork is encoded as a multi-size Windows ICO and embedded in the executable. The installer creates a shortcut using that executable icon. A `windows-v*` tag builds and uploads a ZIP through GitHub Actions.
- **Verification:** Targeted behavior checks passed earlier. Windows x64 self-contained publish passed with the temporary .NET 8.0.426 SDK; the ZIP contains the executable and installer scripts, and the executable's icon can be extracted. The installed executable hash matches the package, its shortcut points to it and uses its icon, and the new process is running.
- **Git:** User explicitly requested push. Generated `dist` remains ignored. Release publication and link verification are pending.
- **Next step:** Commit and push, then verify the GitHub Release asset resolves.
