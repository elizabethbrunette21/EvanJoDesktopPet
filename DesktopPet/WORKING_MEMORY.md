# Working Memory

- **Current task:** Windows preview publication completed; await user runtime feedback.
- **Scope:** Windows x64 package and release workflow, English and Chinese READMEs, and accumulated Windows interaction changes explicitly requested for push.
- **Implementation:** The macOS AppIcon artwork is encoded as a multi-size Windows ICO and embedded in the executable. The installer creates a shortcut using that executable icon. A `windows-v*` tag builds and uploads a ZIP through GitHub Actions.
- **Verification:** Targeted behavior checks passed earlier. Windows x64 self-contained publish passed with the temporary .NET 8.0.426 SDK; the ZIP contains the executable and installer scripts, and the executable's icon can be extracted. The installed executable hash matches the package, its shortcut points to it and uses its icon, and the new process is running.
- **Git:** Main contains the Windows preview commit tagged `windows-v0.1.0-preview.2`. The Windows Release workflow passed and its ZIP is uploaded. Generated `dist` remains ignored.
- **Next step:** User checks ordinary Idle and Loading clicks and animation appearance on the installed app; system-level injected clicks could not be verified in this tool session.
