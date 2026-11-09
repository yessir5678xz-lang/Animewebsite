<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:0053f714012a8f44b80b9b9f5561ecc7558aeae1e05c9e272958bac939976321 -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:c944643e3d454855f995272668a3fd2260a11e062da2c87c1a2bf875578628e9 -->

# 3LANDS OF DEATH, BEAUTY & PROSPERITY

## Current release: v0.3.0 — Roads of the Remembered

Expanded Android ARM64 release: 791 GLB models, 42 surface materials, 45 locations, animated characters, regional choices and trials, and new adaptive audio. See [EXPANSION-v0.3.md](EXPANSION-v0.3.md) for the current feature status, source-pack restoration, build instructions and limitations. Large material sources are supplied as three release assets and must be restored before building a fresh checkout.

The v0.2 notes below are retained as history; the v0.3 guide supersedes their art, audio, location count and graphics-preset descriptions.


<!-- /coderabbit-ai-generated:v1 -->

## v0.2.0 — The Living Covenant

A Godot 4.7.2 Android ARM64 RPG development release. This expands v0.1 with modular RPG rules, streamed wilderness, equipment and skills, contracts, dungeons, economy, skeletal character movement, and ForgeGUI illustrations. The full original AAA-scale game is still in development; the feature status below describes the actual implementation.

## Play

Download the APK from GitHub Releases. Android 7.0/API24 or newer, ARM64 and OpenGL ES3 graphics are required by the package. Hardware performance requirements have not been measured. The build is debug-signed using the same sandbox development key as v0.1; it is not a store release. No extra data download or network connection is required by the game.

Drag the left pad to move, use the action buttons to fight, and hold Guard just before an enemy strike for a perfect parry. The right-side open play area rotates the camera when dragged. Keyboard: WASD, J light, K heavy, L spell, Space evade, B guard, E interact, H heal, Q lock-on, R camera rotation. Controls move relative to camera orientation.

Speak to each land’s keeper near camp and follow the northern road to its warden. Three moral decisions determine one of two endings. Read the Chronicle after recovering all three shards. Use Atlas to change continents. Open Codex for equipment, skills, contracts, companions, settlement, appearance, and local coordinates. Find the chronicler at 12,-9 for additional lore and faction contracts. At night the chronicler walks home. Ancient Descent at 20,-50 enters a dungeon; the southern entrance returns to the frontier.

### RPG play loop

- Ten purchasable weapon categories: sword, greatsword, daggers, spear, axe, bow, crossbow, staff, dual weapons and ember relic. Reach, cost, cooldown, damage and behavior differ. Greatswords cleave, spears reach farther, axes stagger, daggers poison, bows/crossbows/staffs launch projectiles, dual weapons gain a combined hit, relics burn. Melee uses procedural skeletal poses rather than authored motion-capture clips. Weapon mastery adds damage through use.
- Equipment merchants operate at camp. Buy weapons, forge armor, enchant with fire/frost/poison, forge the original blade, buy potions, or rest. All trades consume real resources. Armor, passive Ward, and settlement forts reduce incoming damage.
- Eight five-rank skills across warrior, mage, assassin, ranger and diplomat trees. Each level grants two points. Skills affect health, melee/ranged/spell damage, life siphon, dodge cost, trade prices and damage resistance. Attune the active spell to fire, frost or poison.
- Twelve authored side contracts with descriptions, givers, rewards and faction credit. Accept first, then complete local enemy, delivery, dungeon or testimony goals. Delivery claims consume ore. Rewards can only be claimed once. No generated quest-count padding is used.
- Bellkeepers, Verdant Court and Free Guilds reputations change from decisions, contracts and wardens and affect merchant prices. The three original moral decisions remain irreversible and influence the ending.
- Recruit the sentinel at camp. It gains bond from victories, provides combat assistance and supports follow/guard/stay orders. Guard adds damage mitigation. The sentinel has contextual backstory dialogue; it is not a complete companion romance/relationship simulation.
- Build mines, markets and forts at camp. Mines and markets generate treasury income every 240-second world day; collect it at camp. Commodities have different buy/sell values across continents. This is a working small settlement economy, not a complete kingdom political simulator.

## Exploration and presentation

Each land retains its original camp and warden frontier and extends into deterministic wilderness. A 3×3 neighborhood of 96-unit chunks is loaded around the player; distant chunks are unloaded and their living enemies are stored. MultiMesh vegetation reduces draw calls. Eight named discoveries per continent provide landmarks, exploration XP and unlocked fast travel in the local atlas. These settlements are visual landmarks, not fully populated authored cities. The wilderness is procedurally continuous and has no designed geographic continent boundary.

Each land has an instanced five-room corridor dungeon with enemies and a stronger final guardian. Warden extensions differ: Death summons soldiers, Beauty casts radial projectiles, Prosperity telegraphs a large delayed blast. Core enemy AI still shares the original pursuit/telegraph controller. Loot includes camp treasure chests, ore, gold, and occasional potions. Breakable camp caches yield ore. Camp building collision is implemented; vegetation and most scenic props remain nonblocking.

Characters use Skeleton3D with rigid bone attachments, walk cycles, idle motion, and procedural melee attack poses. Source geometry remains simple original procedural art. Four palette options customize appearance. Fire/poison tick damage and frost causes brief stagger. The combat finisher is a scale/pose effect, not a cinematic execution animation.

A world day lasts 240 seconds. Lighting, rain, storm fog and NPC schedules change with time. LOW/MEDIUM/HIGH/ULTRA presets adjust render scale, shadows, MSAA, local lights, rain and camera view. Adaptive graphics can lower the preset after sustained slow frames. The renderer remains Compatibility/OpenGL; Forward+ and Mobile/Vulkan configurations have not been implemented or validated.

Audio includes original synthesized regional scores, a fading combat layer, impacts, spells, footsteps and boss cues. Music can be muted. Hardware audio focus behavior and audio quality presets remain unverified/unimplemented respectively.

## ForgeGUI assets

The MCP connection authenticated successfully using the user-provided key kept outside the checkout. ForgeGUI produced three 1024px keeper portraits and one world atlas, integrated into dialogue and travel. Artifact references and SHA-256 values are in `game/assets/ui/forgegui-assets.json`. These images were preserved at their source resolution. ForgeGUI’s homepage describes commercial-use rights: https://forgegui.com/terms . Three subsequent panorama requests failed with insufficient_credits; no failed images are represented as delivered. 3D generation was refused by the account’s paid-plan gate. No account key is embedded in the game or build scripts.

## Save compatibility

v0.1 schema1 saves without RPG fields migrate to new defaults. Progression, inventory, skills, contracts, factions, settlements, character settings, overworld position, health, mana, remaining core enemies, ore and streamed enemy records persist. Existing v0.1 quest guarantees are retained. Loading now restores the saved overworld position and resources instead of always returning to camp; travel no longer replenishes core enemies and ore. This intentionally advances the first build toward the original persistence requirement.

Autosaves run every 25 seconds; manual save/load are in System. A temporary write is flushed before rename and a valid prior save is kept as backup. Malformed nested RPG data is rejected. Android pause captures state and saves. Exact dungeon progress is not serialized; loading a dungeon save returns to the land’s camp. Breakable caches replenish on land reload. Backup recovery covers interrupted writes but does not guarantee recovery from a full storage-device failure.

## Build and verification

Install Godot 4.7.2 and matching Android/Web export templates, JDK17, Android SDK/build tools and configure SDK/JDK/debug keystore in Godot editor settings. Signing keys are not in Git.

```sh
GODOT_BIN=/path/to/godot bash tools/build.sh
```

The script imports, runs both gameplay suites and exports Android and Web. Automated assertions cover startup, simulated touch, combat, magic, dodge, all weapon categories, skills, insufficient funds, faction-local quest credit, one-time rewards, economy ticks, save recovery/migration, chunk unload/reload, dungeons, land transitions, wardens, endings, and RPG menu construction. Native screenshot harness: `game/tests/visual_expansion.gd`. Tests use separate save paths. `tools/generate_audio.py` regenerates original audio cues.

Android hardware installation, physical touch, mobile frame rate/memory/battery behavior and offline device operation remain unverified. The sandbox has no connected Android device or /dev/kvm. Shared Chromium previously lacked WebGL2; native rendering was checked using Mesa software rendering and does not establish device performance.

## Remaining original ambition

The complete massive-scale world is not finished. Major remaining work includes professionally authored and populated cities, extensive unique dungeons, hundreds of authored quests, full branching main-story routes beyond the current moral decisions, complex faction diplomacy, assassination guilds, character creation beyond palettes, full skeletal skins and authored animation sets, cinematic executions, ranged weapon geometry and specialized bow animation, sophisticated navigation/tactical AI, full armor/item loot tables, advanced terrain/LOD/occlusion, destruction, cinematic scenes and voice work, four audio quality levels, downloadable/versioned asset package installation, production signing and comprehensive Android device QA. The current status is a playable expanded development release; these systems are not represented by fake menu buttons.

## Architecture

- `game/systems/rules.gd`: validated data-driven equipment, skills, transactions, contract rewards and settlement rules.
- `game/systems/expansion.gd`: RPG gameplay integration, dungeon lifecycle, UI, statuses, projectiles, NPCs, weather and audio transitions.
- `game/systems/streaming.gd`: deterministic nearby chunk loading, unloading, discoveries and persistent enemy state.
- `game/scripts/state.gd`: save/load, migration, backup and progression.
- `game/scripts/actor.gd`, `art.gd`: original skeleton motion and procedural geometry.
- `game/data/rpg.json`, `lands.json`: authored narrative, contracts and equipment definitions.
- `game/scripts/main.gd`: base game, HUD, combat entry points and land lifecycle.

Godot is MIT licensed; its license and third-party notices are included in Credits. No third-party game asset library was imported.


<!-- /coderabbit-ai-generated:v1 -->