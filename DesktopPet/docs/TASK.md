# Current Task

<!-- task-status:completed-v0.1.0 -->

> **Completed:** The first public repository preparation and release task was
> completed with EvanJoDesktopPet v0.1.0 on 2026-07-31.
>
> The content below is retained as the historical task specification rather
> than an active task.


> Prepare EvanJoDesktopPet for its first public Git commit.

## Status

Complete. Repository hygiene, runtime-asset independence, licensing,
repository-local Git identity, and the exact first-commit candidate set are
verified. No files are staged and no commit, GitHub repository, remote, or
push was created.

## Licensing Boundary

- Source code and project documentation use the MIT License.
- The Evan Jo character name, identity, character design, illustrations,
  animation layers, and other visual assets are excluded from MIT.
- Covered visual material is governed by `ASSET_LICENSE.md` and may be used
  only to build, run, test, and evaluate this project for non-commercial
  purposes.
- Standalone reuse, redistribution, derivative visual works, and commercial
  use of Covered Material are prohibited.

## Verification

- Inspect the exact unignored file set that would enter the first commit.
- Confirm ignored source material, Xcode user state, signing files, secrets,
  caches, and archives remain excluded.
- Confirm there are no oversized GitHub-hosting candidates.
- Build the public candidate source set with signing disabled.
- Report the repository-local Git identity and final unstaged Git status.

The final candidate contains 104 files. A byte-identical clean copy of the
candidate built successfully with signing disabled. The existing MainActor
isolation warning remains the only source warning observed during the build.

## Known Product Follow-ups

- Manual runtime verification remains pending for automatic scheduling and the
  Loading, Speechless, and Brainwave animations.
- The existing MainActor isolation warning in `PetWindowController.swift`
  remains unresolved.
- Release packaging, signing, and notarization remain future work.

## Stopping Condition

Stop when the worktree is ready for a reviewed first commit. Do not stage,
commit, create a GitHub repository, add a remote, or push without new explicit
user approval.
