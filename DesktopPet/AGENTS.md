# EvanJoDesktopPet Agent Instructions

These instructions apply to the entire EvanJoDesktopPet project. Long-lived project documentation is written in English.

## 1. Read Before Act

At the start of every task, Codex must read, in order:

1. `AGENTS.md`
2. `WORKING_MEMORY.md`
3. `PRODUCT_ALIGNMENT.md`
4. `docs/TASK.md`
5. Any other documentation and source files directly related to the task

Do not modify the project based only on the user's latest message. Inspect the current project state and the relevant implementation first.

## 2. Instruction Precedence

When project instructions conflict, apply them in this order, from highest to lowest priority:

1. The currently and explicitly approved task authorization
2. `AGENTS.md`
3. `PRODUCT_ALIGNMENT.md`
4. `docs/TASK.md`
5. `COMMANDS.md`
6. Relevant specialized documentation
7. `WORKING_MEMORY.md`

The required reading order does not change this precedence. `WORKING_MEMORY.md` records current state only and cannot override long-term rules.

## 3. Confirm Before Act

The default workflow is:

1. Analyze the request.
2. Inspect the relevant files.
3. Explain the problem and current state.
4. Propose a small, focused change plan.
5. List the files that would change.
6. Wait for explicit user approval.
7. Only then make code or implementation changes.

If the user explicitly asks for direct execution, the extra confirmation may be skipped, but the existing implementation must still be inspected first. A general direct-execution request does not waive restrictions on protected directories, APIs, image generation, destructive operations, or Git safety; those actions still require the specific approvals defined by the applicable rules.

`WORKING_MEMORY.md` and `docs/TASK.md` record the current approved phase and task and must remain aligned. Do not enter the next phase without explicit user approval.

## 4. Scope Control

- Handle one clearly defined task at a time.
- Prefer the smallest change that satisfies the request.
- Do not add features the user did not request.
- Do not opportunistically refactor unrelated code.
- Do not modify files unrelated to the current task.
- Do not expand scope merely in the name of best practices.
- Do not pull future features into the MVP.
- Do not recreate structures that already exist and remain valid.

## 5. Protected Assets and Directories

The following local archived directory is read-only when present:

`../_archive/tartan-pet-run`

Do not modify, move, rename, clean, or rerun tasks in this directory.

Without new and explicit user approval:

- Do not call the built-in image generator.
- Do not call CLI image generation.
- Do not call the OpenAI API.
- Do not request or read `OPENAI_API_KEY`.
- Do not generate replacement character images.
- Do not overwrite existing reference images.
- Do not rerun Hatch Pet preparation.
- Do not modify any existing Hatch Pet manifest or job state.

## 6. Technical Direction

The current planned direction is:

- A native macOS application
- SwiftUI for interface and state
- AppKit only where macOS window behavior requires it
- No third-party dependencies during the MVP
- No backend
- No account system
- No database
- No AI or network dependency
- Local-only state where possible

This direction does not itself authorize code creation or entry into a later phase.

## 7. Verification Budget

For each implementation task:

- The default budget is one general macOS build.
- If the first build reveals a clear error caused by the current change, a second verification build is allowed after a targeted fix.
- Do not repeat the same build when no code or configuration has changed.
- A third or later build requires explicit user approval.
- Only targeted tests directly related to the change
- No automatic long-running tests
- No large temporary test projects
- No subagents
- No unrelated full-project checks
- Manual UI verification only when the user explicitly requests it

If a build fails, analyze the specific error before making a targeted fix. The second-build exception is for verifying that targeted fix, not for an open-ended build/test loop.

## 8. Git Discipline

- Do not include unrelated files in a commit.
- One completed task should correspond to one focused commit.
- Inspect the diff before committing.
- Do not rewrite Git history.
- Do not force-push.
- Do not delete existing user branches.
- Report completed work before any commit and do not commit unless the user explicitly asks.

## 9. Memory Discipline

`WORKING_MEMORY.md` must:

- Stay concise, with a target maximum of about 100 lines.
- Contain only the current valid state.
- Record state only and never override long-term project rules.
- Not become a complete historical log.
- Replace stale information when state changes.
- Record the current phase, current task, key decisions, blockers, protected items, and next step.
- Exclude unrelated conversation details.

## 10. Multi-Character Architecture

- Keep shared desktop-pet engine code character-agnostic.
- Do not hard-code character names or asset names into generic window, interaction, persistence, or scheduling infrastructure.
- Character-specific poses, assets, dimensions, behaviour choices, and animations belong to an internal character pack.
- Add future characters by reusing the existing project and shared engine; never duplicate the entire Xcode project for a character.
- Keep shared-engine refactoring and character-asset work as separate focused tasks with separate approval.
- Internal character packs are bundled Swift/resource organization, not dynamic plugins. Do not create a plugin loader or external package system during the MVP.
- Introduce only the smallest character boundary required by the current and next confirmed character; do not add speculative protocols or framework layers.
