---
name: blender-seinen-art-direction
description: Build, refine, and render Blender assets and presentation renders using a highly detailed original monochrome seinen manga art direction. Use when creating characters, creatures, weapons, environments, props, visual development sheets, cinematic stills, manga-inspired promotional artwork, or Blender automation for this repository.
---

# Blender Seinen Art Direction Skill

## Mission

Use Blender as a production tool to create technically sound 3D assets and high-quality visual development that support **3LANDS OF DEATH, BEAUTY & PROSPERITY**. The governing visual target is **Gritty Cinematic Realism**: mature seinen sensibility, believable anatomy and physical construction, deliberate silhouettes, intricate material detail, dramatic composition, and a traditional black-and-white ink presentation.

This is an original art direction. Study broad craft principles associated with detailed seinen manga—anatomical credibility, brush/pen line hierarchy, cross-hatching, environmental density, negative space, cinematic framing, and legible action—without tracing, reproducing, or imitating any specific manga panel, copyrighted character, artist's signature design, or page layout.

## Repository-first requirements

1. Inspect the repository before editing. Read `README.md`, `EXPANSION-v0.3.md`, asset manifests, Godot import settings, existing Blender files, asset-generation scripts, and the current export/build pipeline.
2. Preserve the project's established naming, folder structure, scale conventions, coordinate conventions, material conventions, and licensing requirements.
3. Determine whether an asset already exists before creating a duplicate. Prefer improving or extending existing source assets over replacing them.
4. Keep source assets editable. Do not commit generated caches, temporary renders, machine-specific absolute paths, secrets, or large uncompressed intermediates unless explicitly required.
5. Do not silently modify gameplay logic or change exported asset paths. Check all scene references and manifests before moving or renaming an asset.
6. If a requested feature conflicts with existing project constraints, report the conflict and propose a safe implementation instead of guessing.

## Blender compatibility and automation

- Inspect the installed Blender version and available Python API before relying on version-specific features. Do not assume a version.
- Prefer Blender's bundled Python API (`bpy`) for repeatable scene creation, procedural modeling, materials, cameras, lighting, render setup, validation, and batch export.
- Write scripts to be re-runnable and deterministic. Use explicit seeds for procedural generation, stable object names, clear collections, and idempotent setup functions.
- Support background execution where possible:
  `blender --background --python path/to/script.py`
- Do not assume external Python packages are installed inside Blender. Detect dependencies and provide a clear fallback or installation note.
- Keep Blender source files and exported game assets separate. Export only intended objects and apply transforms when required by the target format.
- For Godot delivery, verify the repository's actual import pipeline and supported formats before selecting GLB/glTF settings. Use consistent unit scale, forward/up axes, material handling, animation export, and texture packing.
- Avoid destructive operations on the only source copy. Save checkpoints or create a new version before major procedural changes.

## Visual identity: Gritty Cinematic Realism

### 1. Shape language and silhouettes

- Use strong, readable primary silhouettes before adding surface complexity.
- Build forms with credible mass, proportion, balance, and contact points.
- Distinguish characters, creatures, armor, weapons, and props through their shape language and construction rather than relying only on texture.
- Keep focal subjects visually dominant. Secondary detail must support rather than obscure their read.

### 2. Anatomy and character construction

- Use believable skeletal proportions, joint placement, muscle groups, weight distribution, and range of motion.
- Check anatomy from front, side, back, three-quarter, and action views.
- Make hands, feet, necks, shoulders, and facial planes intentional; do not hide weak construction with darkness or camera angles.
- For rigged characters, validate deformation at shoulders, elbows, wrists, hips, knees, ankles, and neck. Test extreme but plausible poses.
- Keep character identity consistent across turnarounds, poses, expressions, and shots.

### 3. Material-specific detail

Model and shade surfaces according to their physical construction:
- Skin: subtle plane changes and restrained pore/roughness detail; never plastic or waxy.
- Hair: coherent clumps and flow direction, not random spikes.
- Cloth: believable thickness, seams, folds, tension, and gravity.
- Leather: edge wear, creases, stitching, and restrained specularity.
- Metal: physically plausible thickness, bevels, scratches, dents, oxidation, and controlled reflections.
- Stone: layered fracture logic, chips, roughness, and scale-consistent erosion.
- Wood: grain direction, joins, splits, tool marks, and wear.
- Organic/creature surfaces: coherent anatomy and growth logic; avoid detail noise without structural purpose.

### 4. Environments and architecture

- Establish scale using doors, stairs, furniture, vegetation, people, and other measurable forms.
- Use correct perspective, structural logic, believable support, and plausible construction.
- Add layered depth: foreground framing, readable midground subject, and atmospheric background.
- Use detailed set dressing selectively: damage, debris, weathering, tools, inscriptions, vegetation, and traces of human use.
- For the game's three lands, preserve each region's established identity and continuity. Derive regional motifs from existing lore and assets rather than inventing contradictory world facts.
- Keep collision and gameplay geometry practical; decorative detail should not accidentally obstruct traversal.

### 5. Monochrome material and lighting system

The canonical presentation is **traditional black-and-white manga**, not a colored render with saturation removed as an afterthought.

Build a controllable monochrome look-development setup:
- Use grayscale values with a deliberate value hierarchy.
- Preserve clear white paper/highlight regions and strong black shadow masses.
- Use lighting to describe form and separate planes, not to create indiscriminate crushed blacks.
- Use shader nodes, compositor nodes, or a dedicated material pass to create controlled tonal bands and hatching masks.
- Cross-hatching should follow form direction and curvature. Do not cover every surface with uniform grids.
- Use stippling and fine texture selectively for atmosphere, skin, stone, smoke, and organic surfaces.
- Use solid blacks for silhouette anchors, deep occlusion, and focal contrast.
- Screentone/halftone patterns must have controlled scale, angle, density, and aliasing behavior.
- Test at final output size; fine lines that vanish or moiré at delivery resolution must be adjusted.
- Keep a physically based material pass available when the asset is also intended for real-time 3D gameplay.

Do not rely on a single global edge-detection filter as the entire art style. Combine contour selection, depth/normal information, material masks, lighting, and hand-authored corrections where necessary.

### 6. Ink line and contour strategy

Use line hierarchy:
- Fine lines for facial features, skin folds, small seams, and surface detail.
- Medium lines for clothing boundaries, muscles, props, and secondary forms.
- Heavy lines for focal silhouettes, foreground elements, and high-contrast overlaps.

Possible Blender implementation routes include Freestyle (where supported), Grease Pencil line art, geometry-based curves, inverted-hull outlines, compositor masks, and hand-authored curve accents. Select the method based on Blender version, export target, and whether the output is a still, animation, or game asset. Validate outline stability across animation and camera movement.

### 7. Cinematic composition

- Build shots around one clear focal idea.
- Use foreground/midground/background separation, motivated perspective, deliberate negative space, and controlled visual density.
- Vary shot scale: environmental wide shots, full-body views, medium shots, close-ups, and extreme close-ups.
- Use strong diagonals and perspective distortion only when they improve spatial clarity.
- Avoid cluttered compositions where every object has equal contrast.
- Use a contact sheet or camera grid to compare shots before committing to final renders.

### 8. Combat and action visualization

When building combat poses or action stills:
1. Establish both participants' positions and facing directions.
2. Make the attack path and intended contact point understandable.
3. Ensure the defender's response is physically possible.
4. Show weight transfer, balance, joint articulation, and weapon grip correctly.
5. Reflect impact through deformation, recoil, debris, displaced cloth, or changed stance—not arbitrary motion streaks alone.
6. Preserve screen direction and spatial continuity across sequential shots.
7. Use motion lines, impact shapes, dust, and debris as graphic accents, not as substitutes for good posing.

For gameplay assets, prioritize readable silhouettes and animation performance over a single dramatic still.

## Asset workflow

### Phase A — Inspect and plan

- Identify the asset's role: gameplay, cinematic, UI illustration, promotional render, or visual reference.
- Inspect relevant existing assets and references.
- Record target dimensions, polygon/texture budget if known, animation requirements, platform constraints, and export destination.
- Write a short asset plan with modeling approach, material strategy, rigging needs, and verification steps.

### Phase B — Blockout

- Establish proportions and silhouette with simple geometry.
- Set real-world scale and origin/pivot intentionally.
- Test composition and camera angles in grayscale.
- Get the primary read correct before adding detail.

### Phase C — High-detail construction

- Add secondary forms, bevels, structural joints, sculptural details, and material-specific wear.
- Use procedural geometry and modifiers where they improve editability.
- Apply subdivision, remesh, decimation, or displacement only with a clear reason and controlled topology.
- Keep topology suitable for deformation when the model is animated.
- Use UVs and texture resolution appropriate to actual viewing distance.

### Phase D — Look development

Create at least:
- A clean neutral material preview.
- A lighting/value study.
- A canonical monochrome ink render.
- A wireframe or topology inspection for production assets.

Compare the result against the original art-direction rules. Iterate on anatomy, silhouette, value grouping, line hierarchy, material readability, and background competition.

### Phase E — Export and integration

- Export only the intended collection/objects.
- Check axis orientation, scale, transforms, origins, normals, UVs, materials, textures, armature, and animation clips.
- Confirm exported file names match the repository's manifests and Godot references.
- Re-import into Godot or run the project's asset validation/build flow when available.
- Inspect the imported result in the actual target renderer. A good Blender viewport/render does not prove the asset is correct in Godot.

### Phase F — Report

For each completed asset, report:
- Source `.blend` path.
- Exported file path(s).
- Blender version and export settings.
- Triangle/vertex count and texture sizes when measurable.
- Materials, UVs, rigging, and animation status.
- Validation performed and any known limitations.
- Screenshots or renders at the intended delivery resolution.

## Quality gates

Do not mark an asset complete until the applicable checks pass:

### Visual
- Silhouette reads at thumbnail size.
- Anatomy and construction are credible.
- Lighting and grayscale values have a clear hierarchy.
- Fine hatching survives the final resolution.
- Material types remain distinguishable in monochrome.
- Background detail supports the subject.
- No accidental clipping, floating parts, bad intersections, or obvious shading artifacts.

### Technical
- Blender file opens without missing dependencies.
- Script runs without unhandled exceptions.
- Object names and collections are deterministic.
- Transforms, normals, UVs, and material slots are valid.
- Rig deformation and animation playback are checked when applicable.
- Exported GLB/glTF is structurally valid and re-imports.
- Godot import and project validation/build checks pass when available.
- Asset paths, references, and manifests remain consistent.

### Performance
- Polygon count and texture memory suit the target device and scene role.
- Avoid unnecessary modifiers, excessive material slots, and duplicated high-resolution textures.
- Use LODs, instancing, atlas textures, and simpler collision meshes when beneficial.
- Do not trade required visual identity for detail that cannot be seen at game camera distance.

## Deliverable conventions

Follow the repository's existing conventions. If none exist, propose rather than silently impose a structure similar to:

```text
art/
  blender/
    source/
    scripts/
    renders/
    lookdev/
  exports/
    characters/
    environments/
    props/
  documentation/
    art-direction/
```

Do not create empty folders just to match this example. Add only the directories needed for real deliverables.

## Reference discipline

Maintain a reference ledger for any externally sourced visual references:
- Source title/creator/site and URL.
- What broad technique is being studied.
- Whether the reference is licensed for the intended use.
- Any restrictions.

Use references to understand principles such as value grouping, brush economy, panel rhythm, material rendering, perspective, and anatomy. Do not trace manga panels or reproduce protected characters, page compositions, or signature designs. Generate original assets consistent with this project's lore.

## Agent execution protocol

When this skill is invoked:
1. Read this skill completely.
2. Inspect the repository and the target asset before editing.
3. State the concrete deliverable and affected paths in the working plan.
4. Implement the asset or Blender automation in small, reviewable steps.
5. Run Blender/background script checks and project-specific validation when available.
6. Inspect final renders and exported assets; do not claim visual validation without examining outputs.
7. Summarize changed files, technical metrics, visual results, and unresolved issues.

Prefer a complete, tested, repository-integrated asset over a large unverified asset dump.
