# Command Workflows

These command templates supplement `AGENTS.md`; they do not override its read-before-act, protected-path, scope, or Git rules. A command applies to one clearly defined task.

## Shared Build Verification Budget

- The default budget is one general macOS build.
- If the first build reveals a clear error caused by the current change, a second verification build is allowed after a targeted fix.
- Do not repeat the same build when no code or configuration has changed.
- A third or later build requires explicit user approval.
- A release-relevant build performed by `/release-check` counts as the general build for that task.

## `/implement`

Use for a feature implementation that the user has already approved.

- **Required reading:** Read `AGENTS.md`, `WORKING_MEMORY.md`, `PRODUCT_ALIGNMENT.md`, `docs/TASK.md`, `docs/PROJECT_MAP.md`, `docs/CONVENTIONS.md`, and every implementation file directly involved.
- **Analysis phase:** Inspect the existing implementation, trace the affected behavior, explain the current state, and list a minimal plan and exact file scope before editing.
- **Allowed scope:** Make only the smallest implementation and documentation changes required for the approved feature. Do not add adjacent features or unrelated refactors.
- **Confirmation requirement:** The command is for already approved work. If the requested behavior or file scope is not yet approved, stop after the plan and wait for explicit approval. A direct-execution request may waive a second confirmation, not inspection.
- **Verification budget:** Follow the shared build verification budget and run only targeted tests directly related to the change. Analyze a failed build before making the targeted fix allowed by that budget.
- **Output format:** Report the outcome, changed files, focused verification and its result, remaining uncertainty, and any user action required.
- **WORKING_MEMORY update rule:** Replace stale current-state entries after the implementation state materially changes; keep the file concise and current rather than appending a history.
- **Git rule:** Inspect the diff first. Do not commit, push, rewrite history, or include unrelated files unless the user explicitly requests the relevant Git action.

## `/debug`

Use to reproduce a defect or locate it from existing evidence before proposing a fix.

- **Required reading:** Read the four mandatory start-of-task documents, `docs/CONVENTIONS.md`, relevant diagnostics, and every source or test file on the affected path.
- **Analysis phase:** Reproduce with the smallest relevant check when practical, or analyze existing evidence. Separate findings into **confirmed cause**, **likely cause**, and **unresolved uncertainty**.
- **Allowed scope:** Diagnose the reported behavior and its direct execution path. Do not begin with a broad rewrite, speculative cleanup, or unrelated testing.
- **Confirmation requirement:** Diagnosis and reporting do not require a second approval. Editing requires the normal plan, file list, and explicit approval unless the user explicitly requested a direct fix.
- **Verification budget:** Use the smallest reproduction and only targeted tests. If a fix is approved and build verification is relevant, follow the shared build verification budget.
- **Output format:** State reproduction status, evidence, confirmed cause, likely cause, unresolved uncertainty, proposed minimal fix, affected files, and verification status.
- **WORKING_MEMORY update rule:** Update only when the diagnosis changes the current blocker, decision, task state, or next step; remove superseded claims.
- **Git rule:** Do not commit diagnostic artifacts or unrelated changes. Inspect any approved fix diff before a user-requested commit.

## `/review`

Use for a read-only review of code, documentation, architecture, or a focused diff.

- **Required reading:** Read the four mandatory start-of-task documents, the applicable conventions and product constraints, the full requested diff, and the directly affected files.
- **Analysis phase:** Check correctness, regressions, scope, maintainability, accessibility where relevant, and missing focused verification.
- **Allowed scope:** Inspect and report only by default. Do not modify files or expand into general cleanup.
- **Confirmation requirement:** No confirmation is needed for read-only review. Any repair requires a separate focused plan and explicit approval unless the user directly asks for fixes.
- **Verification budget:** Prefer static inspection. Run only targeted, non-destructive checks needed to substantiate a finding; if a build is necessary, follow the shared build verification budget.
- **Output format:** List findings first in descending severity, with file location, impact, and concise reasoning. Then list unresolved questions and a short summary. State explicitly when no findings are found.
- **WORKING_MEMORY update rule:** Do not update memory for review commentary alone. Update it only if the accepted project state, blocker, or next gate changes.
- **Git rule:** A default review makes no file or Git changes. Never commit review work automatically.

## `/asset-change`

Use only for character images, transparent PNG files, spritesheets, and resource replacement.

- **Required reading:** Read the four mandatory start-of-task documents, `docs/ASSET_PIPELINE.md`, the relevant resource declarations and loading code, and the metadata for the specific asset. Treat the preserved Hatch Pet run as read-only.
- **Analysis phase:** Identify the source, intended destination, format, dimensions, transparency, naming, ownership, and rollback path. Confirm that an untouched source copy exists before conversion or replacement.
- **Allowed scope:** Change only the approved assets and directly necessary resource references. Do not change application logic by default. Never overwrite the only copy of source material.
- **Confirmation requirement:** Present the asset plan and exact files before changes. Image generation, API or CLI fallback, destructive conversion, Hatch Pet reruns, or manifest/job changes each require new explicit user approval.
- **Verification budget:** Validate only the changed asset contract: file identity, format, transparency, dimensions, naming, spritesheet layout when applicable, and loading through the existing resource path. If a build is necessary, follow the shared build verification budget. Manual UI verification occurs only on explicit request.
- **Output format:** Report source preservation, changed or added assets, resource-reference changes, validation results, rollback path, and any unresolved visual risk.
- **WORKING_MEMORY update rule:** Update current asset status, blockers, canonical asset choice, and next step only when they materially change; do not add an asset history log.
- **Git rule:** Inspect asset and resource diffs before any user-requested commit. Do not commit source references from protected storage, generated intermediates, or unrelated application changes.

## `/release-check`

Use for focused pre-release inspection, not feature development.

- **Required reading:** Read the four mandatory start-of-task documents, relevant product and asset constraints, current build settings, entitlements and permissions, version information, release notes, and known issues.
- **Analysis phase:** Establish the intended release target and inspect build status, packaged resources, permissions, signing readiness, version/build numbers, and known blockers.
- **Allowed scope:** Perform release checks and report results only. Do not develop new features, refactor, change assets, publish, notarize, or alter signing configuration as a side effect.
- **Confirmation requirement:** Read-only inspection and the approved verification build need no extra confirmation. Any file change, signing action, upload, notarization, or publication requires a separate explicit approval.
- **Verification budget:** Follow the shared build verification budget and run only targeted checks needed for resources, permissions, signing readiness, version information, and known issues. Because `/release-check` is read-only, any targeted fix before a second build requires separate explicit approval.
- **Output format:** Provide a pass/block status, checklist results, exact blockers with file locations where available, known issues, and the smallest next action. Distinguish checked facts from items not verified.
- **WORKING_MEMORY update rule:** Update only if release readiness, a blocker, the current phase, or the next gate changes; replace stale release state.
- **Git rule:** Do not change or commit files during the default check. Any approved release fix follows focused diff review and requires a user-requested commit.
