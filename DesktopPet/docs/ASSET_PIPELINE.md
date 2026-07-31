# Asset Pipeline

## Principles

- Evan Jo's identity and reference materials remain in the protected local legacy Hatch Pet run at `../_archive/tartan-pet-run` when present.
- The legacy run is read-only. Source reference files are never overwritten, moved, renamed, cleaned, or regenerated in place.
- A temporary MVP asset and the canonical final asset are separate concepts. A temporary static image must not silently become the authoritative source.
- Future supported runtime formats are a transparent PNG and a validated spritesheet.
- The application should consume a replaceable local-asset abstraction rather than depend on a specific generation workflow.
- Chroma-key removal or any other image conversion must never be performed destructively on the only copy.
- AI image generation is not part of the application runtime.
- Any image generation requires separate, explicit user approval.
- No CLI or API fallback is allowed without separate, explicit user approval. Do not request or read `OPENAI_API_KEY` without that approval.
- The application must remain usable with a static local asset even if Hatch Pet generation is unavailable.

## Asset Roles

- **Source reference:** Preserved identity or design material. It remains untouched and outside the runtime resource contract.
- **Temporary MVP asset:** A replaceable local image suitable for initial application behavior and layout work.
- **Canonical final asset:** A user-approved transparent PNG or validated spritesheet intended for the application resource bundle.
- **Working derivative:** A non-canonical conversion or validation copy that can be discarded and recreated from a preserved source.

These roles must use distinct files or storage locations. Replacing the runtime asset must not alter the source reference.

## Validation Checklist

Before a future asset is accepted into the application:

- Confirm its role, source, owner, and intended destination.
- Confirm that an untouched source or rollback copy exists.
- Verify the filename and resource name follow `docs/CONVENTIONS.md`.
- Verify the declared file type opens correctly and contains no unexpected embedded dependency.
- Verify pixel dimensions, scale expectations, orientation, and visible bounds.
- For a transparent PNG, inspect alpha edges, background removal, cropping, and unwanted matte or color fringe.
- For a spritesheet, validate the full canvas size, frame size, grid, row and column mapping, frame count, direction mapping, animation mapping, transparency, and padding.
- Confirm the asset renders without relying on an absolute path, network request, generation service, Hatch Pet job state, or manifest at runtime.
- Confirm replacement and rollback can occur without changing application behavior or architecture.
- Record any format contract or spritesheet mapping next to the canonical imported asset when implementation is approved.

## Multi-Character Asset Organization

Each bundled character owns its source references, app-ready poses, animation layers, and rollback material. Character assets must not be treated as shared-engine resources merely because the engine renders them.

Recommended conceptual source layout:

```text
SourceAssets/
  Characters/
    EvanJo/
      Poses/
      IdleLayers/
      References/
```

Recommended conceptual app-asset ownership:

```text
Assets.xcassets/
  Characters/
    EvanJo/
      pose and animation assets
```

The current Xcode asset catalog may remain flat when grouping is impractical. Stable character prefixes still make ownership explicit: source/file IDs use lower snake case such as `evan_jo`, while Xcode asset names use a Swift-style prefix such as `EvanJo`.

Per-character rules:

- Preserve untouched source files before any crop, alpha cleanup, conversion, or animation-layer preparation.
- Keep every app-ready asset attributable to one character and one pose or animation role.
- Do not recolor, redraw, destructively replace, or repurpose another character’s asset without focused approval.
- Keep character-specific animation layers with that character’s source and runtime resources, not in generic engine folders.
- Retain rollback assets or a reproducible contract for every accepted derivative.
- Use names such as `evan_jo_idle_head.png` for source/runtime files and `EvanJoIdleHead` for asset-catalog resources.
- A new character receives its own stable ID, prefix, source location, app-ready assets, and rollback record.

No asset is moved or renamed merely to match this conceptual layout without a separate approved asset task.

## Future Legacy Hatch Pet Import Boundary

A future approved import may copy a completed, validated output from the protected legacy Hatch Pet run into the application's own resource area. Import should follow these boundaries:

1. Leave the original legacy Hatch Pet files, manifest, and job state untouched.
2. Select an explicit completed output and preserve its provenance.
3. Validate the image against the application-owned asset contract before adoption.
4. If conversion is required, create a derivative copy outside the preserved source and retain a rollback copy.
5. Store only the application-ready asset and its necessary layout metadata in the application project.
6. Load the asset through a stable local resource name.

The runtime must not parse legacy Hatch Pet manifests, inspect generation-job directories, call Hatch Pet tooling, or depend on Hatch Pet package internals. The legacy run is an optional upstream source; the application owns the import contract.

## Phase 5A Static Asset Integration

- **Selected source reference:** `../_archive/tartan-pet-run/references/reference-01.jpg`
- **Source SHA-256:** `f7a54e152b653a98cec68c8d1b508881f6eb2b2af4c002dc3c70e96fb215fb27`
- **Secondary reference inspected:** `reference-02.png`; it is a 1170 × 2532 phone screenshot containing gallery UI and five poses, so it was not selected.
- **Working copy:** an external temporary `reference-01-source.jpg`, initially hash-identical to the protected source.
- **Crop bounds:** `(left: 70, top: 100, right: 880, bottom: 950)` in the 1020 × 1020 source.
- **Processing:** Crop unrelated margins and the lower-right watermark and signature text; identify near-white background connected to the crop boundary; remove that background; extend only three pixels into the antialiased boundary; suppress JPEG alpha noise; preserve original character and yellow decorative marks without redrawing.
- **Working derivative:** an external temporary `evan_jo_idle_transparent.png`
- **Canonical Phase 5A app asset:** `EvanJoDesktopPet/Resources/Assets.xcassets/EvanJoIdle.imageset/evan_jo_idle.png`
- **Runtime resource name:** `EvanJoIdle`
- **Output contract:** 810 × 850 RGBA PNG with fully transparent canvas edges and aspect-fit rendering.
- **Output SHA-256:** `21ae94615cbb66161cea31dd46c877e41aa13ca6efb5b438be6715f98d33a092`
- **Rollback path:** Remove or replace the application-owned `EvanJoIdle.imageset`; reproduce the derivative from the unchanged protected reference and recorded crop/process contract. The protected source is never altered.
- **Approval state:** Integrated, build-verified, and visually approved before Phase 5B. This static derivative remains the canonical Idle asset and does not supersede the protected reference as the identity source.
- **Generation status:** No image generation, API, Hatch Pet rerun, or network service was used.

## Phase 5B Multi-state Static Poses

The four user-cropped JPG sources are exact copies of the supplied files. They remain under `SourceAssets/EvanJoStates`, are excluded from the application target, and are never overwritten during processing. `EvanJoIdle` remains unchanged as the canonical Idle pose.

| Pose | Source contract | Processing bounds | Application derivative |
| --- | --- | --- | --- |
| Happy | `evan_jo_happy.jpg`, 499 × 462, SHA-256 `7234ade4e43ba38f9f46705b85cc49105ae426c7af1fe2ba31e80ad41ac2973b` | `(8, 49, 472, 462)` | `EvanJoHappy.imageset/evan_jo_happy.png`, 476 × 425 RGBA, SHA-256 `4135f916cf54f95d440f2768fc820904589c9bdacc93522c1756b7ff1017e506` |
| Loading | `evan_jo_loading.jpg`, 409 × 436, SHA-256 `8b396a0dfd568645c8dbeb8d404b007945788b652ea7765a569ec259bd8d5e88` | `(15, 8, 398, 399)` | `EvanJoLoading.imageset/evan_jo_loading.png`, 395 × 403 RGBA, SHA-256 `8e65ad5fa668b4058bf54cd0f079d6f8dd1e332e3ab2b37dd4071ca24eb72ee1` |
| Thinking | `evan_jo_thinking.jpg`, 481 × 451, SHA-256 `7513e12387c8095e95a6a54ffb8d6f00ff85c95a1d515d4b38328508aab7ad56` | `(70, 24, 454, 433)` | `EvanJoThinking.imageset/evan_jo_thinking.png`, 396 × 421 RGBA, SHA-256 `bc02cbd3e133746a6964d574c92d6bbb01b8950a64b3cbc781b5c06a13549e11` |
| Sleepy | `evan_jo_sleepy.jpg`, 475 × 433, SHA-256 `50e66d5d7493c7d57fad2ccdeba9cba2214a216f60030edc3d63d5913cdbbe50` | `(45, 7, 452, 413)` | `EvanJoSleepy.imageset/evan_jo_sleepy.png`, 419 × 418 RGBA, SHA-256 `c5d07ed75e8eb098bf2bb049360cf1af914bae17687fdca3c0e0371d95f59f2b` |

- **Processing:** Starting from each edge, flood-fill only pixels with every channel at least 245 and channel spread no greater than 20. Safely suppress adjacent neutral JPEG matte pixels for at most six pixels without crossing colored content, convert to full RGBA, trim to the alpha bounds shown above, and add 6 pixels of transparent padding.
- **Preserved content:** Happy decorative marks; Loading text and spinner marks; Thinking speech bubble, glasses, and accessories; and the Sleepy blue background shape remain intact.
- **Extraction uncertainty:** The deterministic process does not reconstruct uncertain edges. A one-pixel trace of original JPEG antialiasing may remain and requires user visual review on the actual desktop.
- **Runtime contract:** Idle, Happy, Loading, Thinking, and Sleepy use stable local `EvanJo` asset-catalog names. The Phase 5B import itself contains no image generation, API, network, transition, or animation dependency.
- **Rollback path:** Remove the four Phase 5B imagesets and their pose mappings, then reproduce a derivative from the corresponding unchanged JPG source. The Idle asset is independent and unchanged.
- **Approval state:** All four derivatives are imported, build-verified, and visually accepted. Phase 5B static pose integration is complete.
- **Generation status:** No image generation, API, external service, Hatch Pet rerun, or protected-path modification was used.

### Phase 5B targeted follow-up

- **Display tuning:** Happy uses a runtime display scale of `1.18`, Thinking uses `1.16`, Sleepy remains at `1.025`, and Idle and Loading remain at `1.0`. Every asset keeps the 125 × 132 point aspect-fit content canvas; Happy alone uses a 156 × 140 point transparent panel so its approved artwork size and decorations can coexist without changing the PNG. Final Happy visible bounds and anchored pose switching are visually accepted.
- **Loading cleanup:** Removed five enclosed near-white components from the `LOADING` text at output bounds `(41, 290, 54, 305)`, `(101, 290, 109, 305)`, `(85, 291, 93, 306)`, `(366, 291, 379, 299)`, and `(73, 293, 78, 299)`. Black lettering, spinner marks, and character edges remain unchanged.
- **Thinking cleanup:** Removed two enclosed near-white components at output bounds `(65, 282, 184, 371)` and `(187, 351, 242, 396)`. The curved black line, green accent, and other colored accessories remain unchanged.
- **Output contracts:** Loading remains 395 × 403 RGBA with alpha bounds `(6, 6, 389, 397)`. Thinking remains 396 × 421 RGBA with alpha bounds `(6, 6, 390, 415)`.
- **Source preservation:** All four JPG source hashes remain unchanged. Happy, Sleepy, Idle, and the protected legacy Hatch Pet materials were not modified.
- **Approval state:** Happy's artwork size and complete decorations, Loading, Sleepy, the Loading text cleanup, the Thinking residue cleanup, and anchored pose switching are visually accepted. Phase 5B is complete.

## Evan Jo Naming Migration

- **Character name:** `Evan Jo`
- **Runtime asset prefix:** `EvanJo`
- **File prefix:** `evan_jo`
- **Application source root:** `EvanJoDesktopPet/`
- **Source-state directory:** `SourceAssets/EvanJoStates/`
- **Byte preservation:** All five runtime PNG and four source JPG SHA-256 hashes match their pre-migration values.
- **Legacy exception:** the local `../_archive/tartan-pet-run` directory remained untouched during the naming migration and was later moved to Trash with explicit user approval after project-owned assets were verified.

## Phase 5D1 Layered Idle Assets

- Approved 1254 × 1254 RGBA Head, Body, and Stars sources are preserved under `SourceAssets/Characters/EvanJo/IdleLayers/`.
- Runtime assets are `EvanJoIdleHead`, `EvanJoIdleBody`, `EvanJoIdleSparkle01` through `05`, and `EvanJoIdleSparkleDot`.
- Each sparkle retains the shared 1254 × 1254 canvas. No image generation, recoloring, redrawing, or runtime image processing is used.
- `EvanJoIdle` remains the static rollback asset. Phase 5D1 is complete.

## Phase 5D1 Layered Happy Assets

- Approved 1254 × 1254 RGBA Body, Head, Flowers, and Jump Lines sources are preserved under `SourceAssets/Characters/EvanJo/HappyLayers/`.
- The preserved source SHA-256 hashes are Body `9427f3b11b6ff860b1e055ee52938e24d85e943a2857b88d09e01b3914d705d4`, Head `25d4c8ed04419c2c397bc60ef38ef5b8679863f99974fb59f9b0886f93985339`, Flowers `f17ded510783640e7fc7a7bca3dbd078ce61d626d1095749715ce5b4a733b461`, and Jump Lines `7f1eae6b634db4c54a00c6e8a752ef1711a2c7f1eb0ef9c6ec10bfda4cdc94bd`.
- These are source-preservation copies only. Existing Happy runtime assets and `EvanJoHappy` remain unchanged.

## Phase 5D2 Loading Layers

- **Preserved sources:** `SourceAssets/Characters/EvanJo/LoadingLayers/evan_jo_loading_body_transparent.png`, `evan_jo_loading_spinner_transparent.png`, and `evan_jo_loading_text_transparent.png`.
- **Source contract:** Each source is an untouched 1254 × 1254 RGBA transparent PNG. No recoloring, redrawing, sharpening, generation, or image processing was performed.
- **Provenance:** The preserved Body SHA-256 is `c0adc7b97033ca14140003ae7e2d865aaec067f2d2fc5433180ed5c9da6899a0`; Spinner is `e79c9e3b8a03efda5c114c6526c89fe183788e0949bcde8559086d84088ebf83`; original Text is `4badba7bd0cb363239804fe375cfbb490659d5b4d66e6154bd8e4661de33ba95`.
- **Original/runtime distinction:** `SourceAssets/Characters/EvanJo/LoadingLayers/evan_jo_loading_text_transparent.png` is the untouched original text source. `EvanJoDesktopPet/Resources/Assets.xcassets/EvanJoLoadingText.imageset/evan_jo_loading_text_transparent.png` is the separately cleaned runtime variant with SHA-256 `bc2d905bb64e61691141477123f83b7837ec66e0574fab74699e25435575f857`; the runtime cleanup removed part of the original glyph pixels. They are intentionally different and must never overwrite one another.
- **Runtime assets:** `EvanJoLoadingBody`, `EvanJoLoadingSpinner`, and `EvanJoLoadingText` in the application asset catalog; each retains its imported filename.
- **Fallback:** Static `EvanJoLoading` remains unchanged and is retained as the local fallback asset.
- **Approval state:** Imported and build-verified; user visual/runtime approval of the Loading composition is the next gate.

## Phase 5D3 Thinking Layers

- **Preserved sources:** The untouched Body, Glasses, Bubble, Dots, and Leaf sources are application-owned under `SourceAssets/Characters/EvanJo/ThinkingLayers/`; the untouched complete reference is under `SourceAssets/Characters/EvanJo/References/` with the normalized filename `evan_jo_thinking_full_transparent.png`.
- **Desktop cleanup:** The eight approved desktop copies were removed only after their SHA-256 hashes and PNG metadata were verified against these project-owned copies.
- **Validation:** Body, Bubble, Dots, Leaf, and complete reference are 1254 × 1254 RGBA transparent PNGs; Glasses is 2048 × 512 RGBA. Each has alpha range 0–255. Content bounds are Body `(282, 126)–(1053, 1039)`, Glasses `(397, 55)–(1649, 451)`, Bubble `(403, 348)–(894, 823)`, Dot 1 `(609, 608)–(645, 645)`, Dot 2 `(605, 588)–(649, 632)`, Dot 3 `(603, 607)–(642, 645)`, Leaf `(341, 337)–(915, 863)`, and complete reference `(176, 31)–(1047, 1193)`.
- **Runtime assets:** `EvanJoThinkingBody`, `EvanJoThinkingGlasses`, `EvanJoThinkingBubble`, `EvanJoThinkingDot1`, `EvanJoThinkingDot2`, `EvanJoThinkingDot3`, and `EvanJoThinkingLeaf`. The unused `EvanJoThinkingReference.imageset` was moved to `SourceAssets/Characters/EvanJo/References/ArchivedAssetCatalog/`; the complete composition reference remains preserved but is no longer bundled.
- **Fallback and rollback:** Static `EvanJoThinking` remains unchanged. Remove or replace only the eight Thinking imagesets and the Thinking custom renderer to return to that static fallback; preserved source copies remain available. No recoloring, redrawing, sharpening, alpha processing, generation, network service, or protected-path access was used.
- **Approval state:** Imported and build-verified; user visual/runtime approval of the Thinking composition is the next gate.

## Phase 5D4 Sleepy Layers

- **Preserved sources:** Untouched Mist, original Body, normal/reflection Glasses, Impact Streak, and Yellow Sparkle PNGs remain application-owned under `SourceAssets/Characters/EvanJo/SleepyLayers/`. The focused refinement adds untouched `evan_jo_sleepy_body_back_source.png` and `evan_jo_sleepy_hand_front_source.png` copies from the user-supplied Desktop folder. The Desktop import folder was removed after all eight imported PNGs matched these project-owned copies by SHA-256.
- **Source contract:** Mist is 864 × 744, original Body 887 × 961, both Glasses files 1013 × 358, Impact Streak 1187 × 180, Yellow Sparkle 231 × 261, and both split layers 1024 × 1024. Every file is RGBA with transparent outer edges.
- **Content bounds:** Original bounds remain Mist `(12, 12, 840 × 720)`, Body `(19, 19, 849 × 923)`, both Glasses `(19, 19, 975 × 320)`, Impact Streak `(7, 6, 1178 × 167)`, and Yellow Sparkle `(18, 18, 195 × 225)`. Stable visible bounds using alpha greater than 8 are Body Back `(107, 10, 805 × 930)` and Hand Front `(472, 338, 331 × 456)`.
- **New provenance hashes:** Original Body Back `9f09c2624e47416f3dddccf1ce5ce1fd5e966a5f5ecad86e87e9f5ae42d51ed7`; original Hand Front `b98842e60e46a95bfaf8cef46e95da6d568c0385ceb8a0502ab84c5ced769d0f`; Idle-palette Body Back derivative `9124df7514b0f83152af7e5ee39772062798a1a5cd6e671cfddf12317d3942a9`; Idle-palette Hand Front derivative `1b783fde0fd00cc82681fb391e1c8383a36d12fe7de3d3ca051344e57410040f`.
- **Runtime assets:** The renderer uses `EvanJoSleepyBlueMist`, Idle-palette derivatives in `EvanJoSleepyBodyBack` and `EvanJoSleepyHandFront`, `EvanJoSleepyGlasses`, `EvanJoSleepyGlassesReflection`, and `EvanJoSleepyYellowSparkle`. Original `EvanJoSleepyBody` and `EvanJoSleepyImpactStreak` remain preserved but are not rendered.
- **Layout contract:** Body Back and Hand Front retain their 1024 × 1024 source canvases, but do not share a runtime frame. One full-reference affine mapping uses scene scale `1.151985` around the character's feet. Body Back retains a 130.7 pt visible height; Mist maps to about 149.26 × 128.53 pt; Hand Front's `(472, 338, 331 × 456)` source content maps through the original full-Body hand/sleeve target to about 34.33 × 47.30 pt. Normal and reflection glasses share one geometry and push transform below Hand Front. Yellow Sparkle is the top layer and remains fixed near the left temple.
- **Fallback and rollback:** Static `EvanJoSleepy` remains unchanged. Removing the two split imagesets and reverting the Sleepy custom renderer restores the preserved original layered implementation; removing the custom renderer returns to the static fallback.
- **Processing status:** Project-owned source copies remain untouched. Project-owned runtime derivatives use deterministic semantic palette mapping for hair, skin/blush, outlines, blue plaid, shirt, vest, tie, pants, and shoes based on Idle; dimensions and alpha are unchanged. The external Desktop import folder and the obsolete local tartan run were moved to Trash only after runtime independence and source-copy integrity were verified. No runtime filter, image generation, network service, external API, or protected-path access was used.
- **Approval state:** Imported and build-verified; user visual/runtime verification is pending.

## Phase 0 Constraint

No asset is created, copied, converted, imported, generated, or validated during Phase 0. This document records the future process only.
