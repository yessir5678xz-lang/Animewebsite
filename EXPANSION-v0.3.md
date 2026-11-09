<!-- coderabbit-ai-generated:v1 -->

# v0.3.0 — Roads of the Remembered

This is an expanded playable development release of Three Lands. The original main story, three keeper decisions, endings, equipment, skills, contracts and save guarantees remain. It is not the complete AAA-scale game in the original brief.

## Delivered expansion

- 791 licensed GLB PackedScene assets: 149 vegetation, 311 architecture, 306 props, and 25 animated characters. The library is available to the procedural region composer; these are library counts, not 791 individually authored encounters. Seven Kenney packs supply CC0 assets. 728 imported clips across the character files include repeated animation names on different characters; this is not 728 distinct moves. Existing ForgeGUI portraits and atlas are retained.
- 42 ambientCG CC0 material sets, with source 4K color, OpenGL normal, roughness and ambient occlusion maps where provided, plus derived 1K mobile variants. All materials are assigned to regions. Original high-resolution maps are retained in source packs. Exported textures use VRAM compression and mipmaps.
- 45 named locations, 15 per land, expanding the previous 24 discoveries. Every location has authored Covenant lore and two persistent local choices. Guardian trials require combat before the choice can be claimed. The original main-story mercy/dominion choices are unchanged; these local decisions grant reputation or ore and a one-time gold/XP reward. They do not introduce additional main-story endings.
- Modular settlements, ruins, towers, gardens, rivers, bridges, mountain/cave facades, arenas and dungeon decoration. These are compact explorable landmarks in a streamed wilderness, not fully populated enormous capitals or extensive underground cities. Buildings have collision footprints; most house interiors are not accessible.
- Animated residents, traders and guards with day/night activity. Imported idle, walk, sprint, attack, death, shooting, sitting, interaction and emote clips drive actors. New melee, ranged, hexer and charging enemy behaviors and persistent trial enemies. Ten weapon categories retain their combat statistics and gain equipment silhouettes, including bows, crossbows and staffs.
- Ten original 96-second stereo musical pieces (main, three regions, combat, boss, exploration, story, village and dungeon), plus eight 32-second synthesized environmental loops. Scores crossfade with combat/location changes. World audio uses positional emitters. These are synthesized compositions, not recorded orchestral music or professional voice performances.
- Five graphics presets, a 30 FPS cap on Low and 60 FPS on higher presets, adaptive quality, distance visibility, MultiMesh vegetation, bounded projectile reuse, asynchronous texture requests and chunk unloading. Ultra and Maximum use 4K surfaces only in the player's current chunk; surrounding chunks use 1K maps. Maximum increases particle budgets. Geometry is stylistic low-poly artwork. Compatibility/OpenGL is retained for the existing Android target; desktop-only volumetrics/SSR are not enabled.

## Play

Install the APK from the v0.3.0 release. It includes the playable content and works without a game-data download. Source surface ZIPs are for developers, not additional installation requirements. The package is development/debug signed, using the existing signing key. Back up your saves before changing installed versions; do not uninstall the old app merely to update it, since uninstalling can remove its private saves.

Android package minimum: Android 7.0/API 24, ARM64, OpenGL ES 3. The minimum RAM and sustained frame rate are not established on hardware. Start with Low or Medium on an untested phone. Allow space for the approximately 1.9 GB APK, Android's installation working space, and saves; the exact OS storage overhead is device-dependent.

Use the left joystick and action buttons, or WASD/J/K/L/Space/E/H on a keyboard. Codex → Local map lists all 45 location coordinates. Walk to survey them, then use unlocked fast travel. Interact with each Record of the Covenant at the landmark center. Trials spawn three guardians; defeat them and return to the record to resolve the local choice. Nearby merchants exchange ore or sell draughts. E/Speak skips location camera introductions. System → Graphics exposes all five presets.

## Rebuild the complete project

1. Check out this task branch or the v0.3.0 release source.
2. Download the three `3lands-0.3.0-source-surfaces-*.zip` assets from that same release. Run `python tools/restore_surface_packs.py /path/to/downloads`. It checks SHA-256 before extraction and verifies all model and texture hashes. Large source surfaces are distributed in these packs rather than committed into Git.
3. Install Godot **4.7.2** with matching Android export templates, JDK17 and Android build tools35. Configure the Android SDK, JDK and your own debug/release keystore in Godot editor settings. Signing keys are deliberately absent from source.
4. Run `GODOT_BIN=/path/to/godot BUILD_WEB=0 bash tools/build.sh`. This verifies source bytes, imports resources, runs the original smoke/RPG suites and new content suite, then exports the ARM64 APK. Omitting BUILD_WEB=0 also requests a Web export. Web gameplay has separate browser requirements and is not established by the Android export.
5. For native visual checks: `xvfb-run -a /path/to/godot --audio-driver Dummy --path game --script res://tests/visual_content.gd`.

Reacquisition tools are provided: `tools/import_library.py` imports official downloaded Kenney archives; `tools/import_surfaces.py` downloads ambientCG source archives and derives mobile variants; `tools/compose_score.py` creates the original audio. The latter two use Python with Pillow/numpy and FFmpeg respectively. Source-pack restoration is preferred for reproducing the exact released maps, since upstream libraries can change. The checked-in asset manifests identify sources, licenses, paths, byte sizes and hashes.

## Coverage and remaining limitations

| Requirement | Current result / remaining work |
|---|---|
| Over 1 GB of useful installed content | APK exceeds 1 GB; exact compressed/uncompressed byte counts are in the release inventory. No filler or duplicate size-padding files. |
| Hundreds of props/vegetation/architecture | Asset-count targets met in the imported library; runtime chooses local subsets. Not every component is placed in every region. |
| Three rich continents | 45 compact regional landmarks and streamed wilderness. Vast authored capitals, large traversable underground civilizations, floating-island traversal and complete interiors remain unfinished. |
| Character and creature ecosystem | Animated people, undead/creature source assets and distinct enemy behaviors. Not a broad zoological simulation or a library of unique legendary creature rigs. |
| Animation range | Imported clips include jump/fall/crouch as resources. Full gameplay climbing/swimming, facial acting, authored rolls/parries/finishers and per-weapon bespoke motion-capture sets remain unfinished. |
| Audio | Original synthesized scores/ambience and positional emitters; no recorded voice acting, full Foley library or professional orchestral recordings. |
| Cinematics | Skippable location camera introductions and existing boss presentation; no complete directed story films, facial cinematics or advanced execution scenes. |
| Rendering | PBR maps, lighting, shadows, day/night, weather, particles and water shader. No tested Vulkan Mobile/Forward+ migration, volumetric fog or desktop screen-space effects. |
| Mobile optimization | Streaming, bounded active textures, visibility, instancing, pooling and presets implemented. Physical-device battery, thermal, GPU memory, installation, audio-focus and touch reliability remain unverified. |
| Source and licensing | Source project plus three source surface packs; CC0 manifest and original-work provenance supplied. |
| Full original RPG ambition | Existing RPG systems retained and expanded. Hundreds of branching quests, deep political simulation, extensive armor loot, large bespoke dungeons and AAA art direction remain incomplete. |

## Technical notes

The highest preset does not load every 4K texture simultaneously. Two texture requests may be in flight, owners are weakly referenced, and released chunks invalidate pending assignments. The model cache holds at most 48 source scenes; active instantiated nodes keep their own references. Streamed chunks persist enemy health, positions, archetypes and guardian-trial IDs. Old v0.2 saves migrate to empty regional history; malformed new state is rejected. Local choices pay once. Streaming stays at a 3×3 chunk neighborhood. Scenic foliage is nonblocking; buildings use conservative footprints rather than triangle collision.

Native rendering uses Mesa software OpenGL in this sandbox. Its timing, memory and draw calls are diagnostic; they are not Android performance guarantees. A real ARM64 installation and device testing are still required before treating this build as a production release.
