# Open-Source Release Checklist

## Repository hygiene

- [x] Exclude the protected Hatch Pet run and personal reference images.
- [x] Exclude Xcode user state, build products, local configuration, and signing material.
- [x] Normalize text files and mark image assets as binary.
- [x] Add project, build, contribution, and security documentation.
- [x] Confirm there are no tracked files or published Git history yet.
- [x] Confirm the public repository name: `EvanJoDesktopPet`.
- [x] Draft the repository description: "A native, local-only macOS desktop companion built with SwiftUI and AppKit."
- [ ] Add the GitHub remote after reviewing the initial commit contents.

## Licensing and ownership

- [x] License the source code and project documentation under MIT.
- [x] Confirm the owner has the right to publish every bundled Evan Jo runtime image.
- [x] Add `ASSET_LICENSE.md` for the Evan Jo character and visual materials.
- [x] Confirm that the character name, identity, design, illustrations, animation layers, and derivative artwork may be published under the stated restrictions.

The source code and project documentation are open source under MIT. The Evan
Jo character and Covered Material defined in `ASSET_LICENSE.md` are not open
source and may be used only within that limited license.

## Product readiness

- [x] Complete one signing-disabled Debug build from the current worktree.
- [x] Build the exact unignored public candidate from a clean temporary copy.
- [ ] Resolve the existing MainActor isolation warning in `PetWindowController.swift`.
- [ ] Complete the documented manual runtime verification.
- [ ] Decide whether pre-release limitations belong in GitHub issues or a roadmap.
- [ ] Add a release build, signing, notarization, and distribution plan when binary releases are intended.
- [ ] Add automated CI only after the public source set can build from a clean checkout.

## Git management

- Keep `main` releasable and protect it after the repository is published.
- Use short-lived feature branches and focused pull requests.
- Require a passing build check before merging once CI exists.
- Use tagged versions such as `v0.1.0` for public releases.
- Do not commit generated archives, app bundles, DerivedData, credentials, certificates, or notarization files.
