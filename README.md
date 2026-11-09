<!-- coderabbit-ai-generated:v1 -->

# 3LANDS OF DEATH, BEAUTY & PROSPERITY

## v0.1.0 — The Broken Covenant

A playable Godot 4.7.2 development release with three stylized 3D frontiers and a branching covenant story. This is the first playable implementation, not the completed massive-scale AAA RPG.

### Play

Open `game/project.godot` with Godot 4.7.2. WASD moves; J strikes, K attacks heavily, L casts an area spell, Space evades, B guards (timing a guard produces a perfect parry), E speaks, H heals. Touch devices use the left-side drag control and labeled action buttons. Use the Atlas to travel. Speak to each keeper and follow the northern road to its warden. Defeat all three and read the Chronicle for your ending. Recruit a sentinel and trade or forge at camp.

### Implemented

- Three separate 190×190-unit frontiers: Vesper, Lethiel, and Aurelis. Only one land's scene is retained at a time. Deterministic procedural scenery, original terrain/water shaders, lanterns, camps, landmarks, ore, regular enemies, and a warden in each land.
- Light/heavy attacks, a three-hit damage combo, evasive invulnerability, blocking, timed parry, area magic, telegraphed enemy attacks, and faster warden attack cadence below half health.
- Three keeper conversations loaded from JSON, three moral decisions, quest tracking, and two narrative endings.
- Gold, consumables, ore, forging, level progression, a recruitable combat companion, and camp recovery.
- Persistent progress, 25-second autosave, manual save/load, interrupted-save backup recovery, Android pause saving, and Android back handling. Travel/load returns the player to camp; frontier enemies and ore replenish.
- Shadow toggle, music toggle, larger touch buttons, original synthesized zone music and impacts.
- Android ARM64 export and a web export. No online service or downloaded assets are required by the APK.

### Build and test

Install matching Godot export templates, JDK 17, Android platform/build tools and configure the Android SDK/JDK/debug keystore in Godot editor settings. APK is a **debug-signed development build**, not a production/store release. Signing keys are not committed.

```sh
godot --headless --path game --editor --import --quit
godot --headless --path game --script res://tests/smoke.gd
godot --headless --path game --export-debug Android
godot --headless --path game --export-release Web
```

The smoke test uses separate test save files. It checks startup, damage, magic, dodge, quest choice, save/load, recovery from a corrupt primary save, land transitions, warden rewards, and ending access. The native visual harness is `game/tests/visual.gd` and uses a separate visual save. `tools/generate_audio.py` reproduces the original soundtrack and impact sample.

### Android requirements and verification limits

Manifest minimum: Android 7.0 / API 24. Architecture: arm64-v8a only. OpenGL ES 3 graphics are required by the Compatibility renderer. Actual minimum RAM, frame rate, battery use, and device-specific behavior have not been established. Godot exports and APK signature/architecture inspections pass. Native software-rendered scene captures pass. No Android device was available; installation, physical touchscreen behavior, audio focus, restart persistence on Android, offline device operation, and sustained mobile performance remain unverified. The sandbox's shared Chromium lacks WebGL2, so browser play could not be verified there.

### Known limitations and expansion backlog

The original ambitious design remains the direction for future releases. Current art is simple procedural geometry; characters lack skeletal animation and portrait art. Frontier decorations do not have collision. Wardens share a combat controller and differ in stats rather than unique mechanics. The companion has no relationship arc. There are no hundreds of side quests, full dungeons, cinematic sequences, weapon categories/movesets, bows, skill trees, armor inventory, factions, NPC schedules, kingdom economics, weather, destructible scenery, or downloadable expansion installer. There are no four graphics presets or Forward+/Mobile rendering paths yet: the current build uses Compatibility rendering with a shadow toggle. Save progress is persistent but exact position, current health, ore depletion, and regular enemy state are not retained. Music and impact synthesis are basic. These are unfinished production features, not hidden or nonfunctional buttons.

The architecture separates save/progression state, procedural art helpers, input/UI/gameplay coordination, external world/narrative data, shaders, and test harnesses. Further work should split combat, world generation, inventory, and dialogue into separate scene components before expanding the content substantially. No content was removed to meet the chat attachment limit.

### Assets and dependencies

Game geometry, shaders, narrative, and audio are original to this project. Godot is MIT licensed: https://godotengine.org/license/. Android export includes Godot and its dependency notices. No third-party game asset pack was imported.
